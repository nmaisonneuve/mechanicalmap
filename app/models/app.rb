class App < ActiveRecord::Base

  STATE = {
    READY: 0,
    INDEXING: 2
  }

  GOOGLE_TABLE_REG = /https:\/\/www\.google\.com\/fusiontables\/DataSource\?docid=(.*)/
  GIST_REG = /https:\/\/gist\.github.com\/(.*)/

  has_many :tasks, :dependent => :destroy
  has_many :answers, :through => :tasks
  has_many :contributors, :through => :answers, :source => :user, :uniq => true
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :challenges_table_url
  validates_presence_of :answers_table_url
  validates_presence_of :gist_url

  validates_format_of :challenges_table_url, :with => GOOGLE_TABLE_REG
  validates_format_of :answers_table_url, :with => GOOGLE_TABLE_REG
  validates_format_of :gist_url, :with => GIST_REG

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
                  :user_id

  before_validation :complete_with_default_values
  after_create :post_processing

  def complete_with_default_values
    self.gist_url = Gist.new(3543287).clone.url if gist_url.blank?
    self.answers_table_url = FtDao::TABLE_BASE_URL + FtDao.create_answers_table(user.email) if answers_table_url.blank?
    self.challenges_table_url = FtDao::TABLE_BASE_URL + FtDao.create_challenges_table(user.email) if challenges_table_url.blank?
    self.image_url = "http://payload76.cargocollective.com/1/2/88505/3839876/02_nowicki_poland_1949.jpg" if image_url.blank?
  end

  def post_processing
    download_source_code
    index_tasks
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
    clone.gist_url = Gist.new(gist_id).clone.url
    clone.script = self.script
    clone.redundancy = self.redundancy
    clone.iframe_width = self.iframe_width
    clone.iframe_height = self.iframe_height
    clone
  end

  def index_tasks
   if Rails.env == "production"
      FtIndexer.perform_async(self.id)
    else
      FtIndexer.new().perform(self.id)
    end
  end

  def add_task(data)
    task_id = next_generated_task_id
    # we fill the task_ID column with the next generated task_id
    data.each { |row|
      row[app.task_column] = task_id
    }
    # insert the task on the FT
    FtDao.instance.enqueue(challenges_table_id, data)
    # add the task as it was just indexed
    FtIndexer.new().index_task(task_id, self.id, self.redundancy)
  end

  def sync_answers
    to_synch = self.answers.merge(Answer.to_synchronize)
    FtDao.instance.sync_answers(to_synch)
  end

  def upload_source_code
    Gist.new(gist_id).script = script
  end

  def download_source_code
    self.script = Gist.new(gist_id).script
    self.save
  end

  def next_task(context)
    task_manager.perform(context)
  end



  ########## PERSISTENCE AND MODEL ATTRIBUTE #################

  def task_manager
    #choice of the task manager
    (redundancy <= 0)? TasksManagerFree.new(self) : TasksManager.new(self)
  end

  def gist_id
    GIST_REG.match(gist_url)[1] unless gist_url.nil?
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

  def clone_answers_table
    clone_table_id = FtDao.clone_table(answers_table_id,"Answers Table", user.email)
    "https://www.google.com/fusiontables/DataSource?docid=#{clone_table_id}"
  end

end