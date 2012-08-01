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
                  :gist_id,
                  :redundancy,
                  :iframe_width,
                  :iframe_height,
                  :state

  def completion
    completed=self.answers.answered.count
    size=self.answers.count
    [completed, size]
  end

  def last_contributor(max_contributors=5)
    self.answers.answered.order("answers.updated_at desc").limit(max_contributors)
  end

  def schema
    FtDao.instance.get_schema(self.output_ft)
  end

  def clone
    clone = App.new
    clone.name = "copy of #{self.name}"
    clone.description = "copy of #{self.description}"
    clone.input_ft = self.input_ft
    clone.script = self.script
    clone.gist_id = GistDao.instance.fork_gists(self.gist_id) unless (self.gist_id.nil?) 
    clone.redundancy = self.redundancy
    clone.iframe_width = self.iframe_width
    clone.iframe_height = self.iframe_height
    return clone
  end

  def index_tasks_async
    self.status = STATE_INDEXING
    self.save
    FtIndexer.perform_async(self.id)
  end

  def add_task(rows)
    # increment the task_id
    last_known_task = self.tasks.order('input_task_id desc').first 
    task_id = last_known_task.input_task_id + 1
    rows.each { |row|
      row[self.task_column] = task_id
    }
    # insert the task on the FT
    FtDao.instance.enqueue(self.input_ft, rows)

    # add the task as it was just indexed
    task = Task.create(:input_task_id => task_id, :app_id => self.id)
      if (self.redundancy > 0)
        self.redundancy.times do
          task.answers << Answer.create!(:state => Answer::STATE[:AVAILABLE])
        end
      end
    task.save
    task
  end

  def index_tasks
    i=0
    self.tasks.destroy_all
    Task.transaction do
      FtDao.instance.import(self.input_ft, self.task_column) do |task_id|
        unless task_id.blank?
        task=Task.create(:input_task_id=> task_id.to_i, :app_id => self.id)
        if (self.redundancy>0)
          self.redundancy.times do
            task.answers<<Answer.create!(:state => Answer::STATE[:AVAILABLE])
          end
        end
        task.save
        i=i+1
        break if (i> MAX_ANSWERS)
      end
      end
    end
    self.status=STATE_READY
    self.save
  end

  def create_schema(schema_param, email)
      schema=[{"name"=>"task_id", "type"=>"number"},
                {"name"=>"user_id", "type"=>"string"},
                {"name"=>"created_at", "type"=>"datetime"},
                {"name"=>"answer", "type"=>"text"}]
      schema=ActiveSupport::JSON.decode(schema_param) unless  schema_param.blank?
      FtGenerator.perform_async(self.id, schema,email)
  end

  def sync_answers
    to_synch = self.answers.merge(Answer.to_synchronize)
    puts "#{to_synch.size} answers to synchronize from app #{self.name}"
    if (to_synch.size>0)
      FtDao.instance.sync_answers(to_synch)
    end
  end

  def synch_gist
    #create gist if not existing
    if gist_id.nil?
      self.gist_id=GistDao.instance.create_gists(self.name,self.script)
      self.save
    else
      GistDao.instance.update_gists(self.gist_id,self.script)
    end
    self.gist_id
  end


  def next_task(context)
    if (self.redundancy==-1)
      worfklow_free(context)
    else
      worfklow_allocation(context)
    end
  end

  def worfklow_free(context)
    tasks = self.tasks.not_done_by_username(context[:current_user])
    tasks=tasks.where('tasks.input_task_id>?', context[:from_task]) unless (context[:from_task].blank?)
    task=tasks.order('tasks.input_task_id asc').first
    return nil if (task.nil?)
    task
  end

  def worfklow_allocation(context)
    tasks=self.tasks.available.not_done_by_username(context[:current_user])

    # if random order
    if (context[:random])  
      tasks=tasks.where('tasks.input_task_id!=?', context[:from_task]) unless (context[:from_task].blank?)
      task=tasks.order('random() ').first
    else
      tasks=tasks.where('tasks.input_task_id>?', context[:from_task]) unless (context[:from_task].blank?)
      task=tasks.order('tasks.input_task_id asc').first
    end
    return nil if (task.nil?)
    task
  end

end
