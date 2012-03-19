class App < ActiveRecord::Base

  has_many :tasks, :dependent => :destroy
  has_many :units, :through => :tasks
  belongs_to :user

  validates_presence_of :name, :script

  attr_accessible :name, :description, :output_ft, :input_ft, :script, :script_url, :ui_template


  def completion
    completed=self.units.completed.count
    size=self.units.count
    [completed, size]
  end

  def ft_insert(rows)
    FtDao.instance.enqueue(self.output_ft, rows)
  end



  def ft_create(schema, user)
    cols=ActiveSupport::JSON.decode(schema)
    self.output_ft=FtDao.instance.create_table(self.name, cols)
    FtDao.instance.set_permission("table:#{self.output_ft}", user.email)
  end

  def schedule(context)
    tasks=self.tasks.opened.available_for(context[:current_user])
    unless (context[:from_task].blank?)
      tasks=tasks.where('tasks.id>?', context[:from_task])
    end
    task=tasks.order('tasks.id asc').limit(1).first
    return nil if (task.nil?)
    task.units.available.first
  end



end
