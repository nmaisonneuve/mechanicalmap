class Area < ActiveRecord::Base
  belongs_to :project
  has_many :tasks

  scope :not_annotated_by, lambda { |user|
    area_ids=Area.joins(:tasks).where("tasks.state=?", Task::COMPLETED).where("tasks.user_id=?", user)
    unless (area_ids.empty?)
      where("#{self.table_name}.id not in (?)", area_ids)
    end
  }

  def completion
    completed=self.tasks.completed.count
    size=self.tasks.count
    [completed, size]
  end

end
