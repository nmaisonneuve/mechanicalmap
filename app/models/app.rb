class App < ActiveRecord::Base

  MAX_ANSWERS=10000 # demo mode

  has_many :tasks, :dependent => :destroy
  has_many :units, :through => :tasks
  has_many :contributors, :through => :units, :source => :user, :uniq => true

  belongs_to :user
  validates_presence_of :name, :script
  validates_presence_of :input_ft, :message => "The ID of the input fusion table can't be blank"
  attr_accessible :name, :description, :output_ft, :input_ft, :script, :script_url, :ui_template


  def completion
    completed=self.units.answered.count
    size=self.units.count
    [completed, size]
  end

  def ft_insert_answer(rows)
    FtDao.instance.enqueue(self.output_ft, rows)
  end


  def ft_index_tasks(redundancy)
    i=0
    Task.transaction do
      FtDao.instance.import(self.input_ft, 10000) do |task_id|
        task=Task.create(:input => task_id, :app_id => self.id)
        # just one answer for the moment
        redundancy.times do
          task.units<<Unit.create!(:state => Unit::AVAILABLE)
          # demo mode .. only 10.000 max answer
          i=i+1
        end
        task.save
        break if ((i>1) && (1% MAX_ANSWERS==0))
      end
    end
  end


  def ft_create_output(schema, user)
    cols=ActiveSupport::JSON.decode(schema)
    p cols
    self.output_ft=FtDao.instance.create_table("Answers of #{self.name}", cols)
    self.save

    # set permission exportable
    FtDao.instance.set_exportable(self.output_ft)
    unless (user[/@gmail/].nil?)
      FtDao.instance.change_ownership(self.output_ft, user)
    end
  end

  def last_contributor
    self.units.where("units.user_id!= null").order("units.updated_at desc").limit(5)
  end

  def schedule(context)
    tasks=self.tasks.available.not_done_by(context[:current_user])

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
    task.units.available.first
  end


end
