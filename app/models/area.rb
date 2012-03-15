class Area < ActiveRecord::Base
  belongs_to :project
  has_many :tasks

  scope :opened, lambda{
     joins(:tasks).group("areas.id").merge(Task.available)
  }

  scope :not_annotated_by, lambda { |user|
    # not optimized
    area_ids=Area.joins(:tasks).where("tasks.state=?", Task::COMPLETED).where("tasks.user_id=?", user)
    unless (area_ids.empty?)
      where("#{self.table_name}.id not in (?)", area_ids)
    end
  }

  def annotated_by?(user)
    user.areas.where("areas.id=?",self.id).exists?
  end

  def check_state
    if (self.tasks.open.count==0)
      Task.aggregate(self.tasks)
    end
  end

  def completion_ratio
    completed,size=self.completion
    completed.to_f/size.to_f
  end

  def completion
    completed=self.tasks.completed.count
    size=self.tasks.count
    [completed, size]
  end

end
