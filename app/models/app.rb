class App < ActiveRecord::Base

  MAX_ANSWERS=10000
  MAX_TASKS=10000

  STATE_READY=0 #NORMAL
  STATE_INDEXING=1

  # demo mode

  has_many :tasks, :dependent => :destroy
  has_many :answers, :through => :tasks
  has_many :contributors, :through => :answers, :source => :user, :uniq => true
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :input_ft, :message => "The ID of the input fusion table can't be blank"

  attr_accessible :name,
                  :description,
                  :output_ft,
                  :input_ft,
                  :task_column,
                  :script,
                  :script_url,
                  :redundancy,
                  :iframe_width,
                  :iframe_height,
                  :state

  def completion
    completed=self.answers.answered.count
    size=self.answers.count
    [completed, size]
  end

  def last_contributor
    self.answers.where("answers.user_id!= null").order("answers.updated_at desc").limit(5)
  end

  def schema
    FtDao.instance.get_schema(self.output_ft)
  end

  def clone
    clone= App.new
    clone.name="copy of #{self.name}"
    clone.description="copy of #{self.description}"
    clone.input_ft=self.input_ft
    clone.script=self.script
    clone.redundancy=self.redundancy
    clone.iframe_width=self.iframe_width
    clone.iframe_height= self.iframe_height
    return clone
  end

  def reindex_tasks
    self.input_state=INPUT_INDEX
    FtIndexer.perform_async(self.id)
  end

  def synch_answers
    to_synch=answers.answered.where(:ft_sync => false)
    if (to_synch.size>0)
      puts "#{to_synch.size} answers to synchronize"

      FtDao.instance.sync_answers(to_synch)
    end
  end

  def index_tasks
    Task.transaction do
      FtDao.instance.import(self.input_ft, MAX_TASKS) do |task_id|
        task=Task.create(:input => task_id.to_i, :app_id => self.id)
        self.redundancy.times do
          task.answers<<Answer.create!(:state => Answer::AVAILABLE)
        end
        task.save
        break if (i> MAX_ANSWERS)
      end
    end
  end

  def next_task(context)
    tasks=self.tasks.available.not_done_by_username(context[:current_user])

    # if random order
    if (context[:random])
      unless (context[:from_task].blank?)
        tasks=tasks.where('tasks.id!=?', context[:from_task])
      end
      task=tasks.order('random() ').limit(1).first
    else
      unless (context[:from_task].blank?)
        tasks=tasks.where('tasks.id>?', context[:from_task])
      end
      task=tasks.order('tasks.id asc').limit(1).first
    end
    return nil if (task.nil?)
    task.answers.available.first
  end

end
