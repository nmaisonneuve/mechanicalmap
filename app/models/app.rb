class App < ActiveRecord::Base

  STATE = {
    READY: 0,
    INDEXING: 2
  }

  GOOGLE_TABLE_REG = /https:\/\/www\.google\.com\/fusiontables\/DataSource\?docid=(.*)/
  GIT_REG = /https:\/\/gist\.github.com\/(.*)\/?/

  has_many :tasks, :dependent => :destroy
  has_many :answers, :through => :tasks
  has_many :contributors, :through => :answers, :source => :user, :uniq => true
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :challenges_table_url
  validates_presence_of :answers_table_url

  attr_accessible :name,
                  :description,
                  :answers_table_url,
                  :challenges_table_url,
                  :gist_url,
                  :task_column,
                  :script,
                  :redundancy,
                  :iframe_width,
                  :iframe_height,
                  :state,
                  :image_url,
                  :user

  before_create :complete_with_default_values
  after_create :post_processing

  def complete_with_default_values
    self.gist_url = clone_gist(3543287) if gist_url.blank?
    self.answers_table_url = FtDao.create_answers_table  if answers_table_url.blank?
    self.challenges_table_url = FtDao.create_challenges_table  if challenges_table_url.blank?
    self.image_url = "http://payload76.cargocollective.com/1/2/88505/3839876/02_nowicki_poland_1949.jpg" if image_url.blank?
  end

  def post_processing
    synch_source_code
    index_tasks_start
  end

  # delete all answers without
  # deleting the challenges
  def delete_answers
    ActiveRecord::Base.execute("DELETE FROM answers inner joins tasks on answers.task_id=tasks.id inner join apps on tasks.app_id = apps.id where apps.id = #{self.id}")
    FtDao.instance.delete_all(app.answers_table_url)
  end

  def clone
    clone = App.new
    clone.name = "Copy of #{self.name}"
    clone.description = "copy of #{self.description}"
    clone.challenges_table_url = self.challenges_table_url
    clone.answers_table_url = clone_answers_table
    clone.gist_url = clone_gist
    clone.script = self.script
    clone.redundancy = self.redundancy
    clone.iframe_width = self.iframe_width
    clone.iframe_height = self.iframe_height
    clone
  end

  def add_task(data)
    task_id = self.next_generated_task_id
    # we fill the task_ID column with the next generated task_id
    data.each { |row|
      row[app.task_column] = task_id
    }
    # insert the task on the FT
    FtDao.instance.enqueue(challenges_table_url, data)
    # add the task as it was just indexed
    indexer = FtIndexer.new()
    indexer.index_task(task_id, self.id, redundancy)
  end

  def index_tasks
   if Rails.env == "production"
      FtIndexer.perform_async(self.id)
    else
      FtIndexer.new().perform(self.id)
    end
  end

  def sync_answers
    to_synch = self.answers.merge(Answer.to_synchronize)
    FtDao.instance.sync_answers(to_synch)
  end

  def synch_source_code
    GistDao.instance.update_gists(gist_id, self.script)
  end

  def next_task(context)
    task_manager.perform(context)
  end

  ########## PERSISTENCE AND MODEL ATTRIBUTE #################

  def task_manager
    #choice of the task manager
    (redundancy == -1)? TasksManagerFree.new(self) : TasksManager.new(self)
  end

  def gist_id
    GIT_REG.match(gist_url)[1] unless gist_url.nil?
  end

  def answers_table_id
    gf_table_id(answers_table_url)
  end

  def challenges_table_id
    gf_table_id(challenges_table_url)
  end

  def last_contributor(max_contributors = 5)
    self.answers.answered.order("answers.updated_at desc").limit(max_contributors)
  end

  def answer_schema
    FtDao.instance.get_schema(answers_table_url)
  end

  def completion
    {completed: self.answers.answered.count,
      total: self.answers.count}
  end

  def next_generated_task_id
    last_known_task = app.tasks.order('input_task_id desc').first
    last_known_task.input_task_id + 1
  end

protected

  def gf_table_id(gf_table_url)
     GOOGLE_TABLE_REG.match(gf_table_url)[1]
  end

 def clone_gist(gist_id = self.gist_id)
    cloned_gist_id = GistDao.instance.fork_gists(gist_id)
    "https://gist.github.com/#{gist_id}"
  end

  def clone_answers_table
    clone_table_id = FtDao.clone_table(answers_table_id, table_name, user.email)
    "https://www.google.com/fusiontables/DataSource?docid=#{clone_table_id}"
  end

end