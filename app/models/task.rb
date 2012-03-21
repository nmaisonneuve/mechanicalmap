class Task < ActiveRecord::Base

  belongs_to :app
  has_many :units, :dependent => :destroy
  attr_accessible :state, :input, :app_id
  serialize :input

  scope :available, lambda {
    joins(:units).group("tasks.id").merge(Unit.available)
  }

  scope :available_for, lambda { |user|
    # not optimized
    tasks_done_ids=Task.joins(:units).where("units.state!=?", Unit::AVAILABLE).where("units.user_id=?", user)
    unless (tasks_done_ids.empty?)
      where("#{self.table_name}.id not in (?)", tasks_done_ids)
    end
  }

  def done_by?(user)
    self.units.where("units.user_id=?",user).count!=0
  end

  def completion_ratio
    completed, size=self.completion
    completed.to_f/size.to_f
  end

  def completion
    completed=self.units.completed.count
    size=self.units.count
    [completed, size]
  end

end
