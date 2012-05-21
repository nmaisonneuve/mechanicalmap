class App < ActiveRecord::Base

  # demo mode

  has_many :tasks, :dependent => :destroy
  has_many :answers, :through => :tasks
  has_many :contributors, :through => :answers, :source => :user, :uniq => true

  belongs_to :user
 # validates_presence_of :name, :script
  validates_presence_of :input_ft, :message => "The ID of the input fusion table can't be blank"
  attr_accessible :name, :description, :output_ft, :input_ft, :script, :script_url, :ui_template


  def completion
    completed=self.answers.answered.count
    size=self.answers.count
    [completed, size]
  end

  def ft_insert_answer(rows)
    FtDao.instance.enqueue(self.output_ft, rows)
  end


  def ft_index_tasks(redundancy)
    i=0
    Task.transaction do
      FtDao.instance.import(self.input_ft, 100000) do |task_id|

        task=Task.find_or_create_by_input_and_app_id(:input => task_id, :app_id => self.id)
        # just one answer for the moment
        redundancy.times do
          task.answers<<Answer.create!(:state => Answer::AVAILABLE)
          i=i+1
        end
        task.save
        break if (i> MAX_ANSWERS)
      end
    end
  end


  def ft_create_output(schema, user_email)
    cols=ActiveSupport::JSON.decode(schema)

    self.output_ft=FtDao.instance.create_table("Answers of #{self.name}", cols)
    self.save

    # set permission exportable
    FtDao.instance.set_exportable(self.output_ft)
    FtDao.instance.change_ownership(self.output_ft, user_email)
  end

  def last_contributor
    self.answers.where("answers.user_id!= null").order("answers.updated_at desc").limit(5)
  end

  def schedule(context)
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
