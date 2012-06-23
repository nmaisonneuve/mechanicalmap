class Task < ActiveRecord::Base

  belongs_to :app

  has_many :answers, :dependent => :destroy

  attr_accessible :state, :input, :app_id, :gold_answer

  serialize :input

  scope :available, lambda {
    joins(:answers).where("answers.state=?", Answer::AVAILABLE)
  }

  scope :done_by_username, lambda { |username|
    joins(:answers=>:user).where("answers.state!=?", Answer::AVAILABLE).where("users.username=?", username)
  }

  scope :not_done_by, lambda { |user|
    # not optimized
    tasks_done_ids=Task.joins(:answers).where("answers.state!=?", Answer::AVAILABLE).where("answers.user_id=?", user)
    unless (tasks_done_ids.empty?)
      where("#{self.table_name}.id not in (?)", tasks_done_ids)
    end
  }

  scope :not_done_by_username, lambda { |username|
    # not optimized
    tasks_done_ids=Task.joins(:answers=>:user).where("answers.state!=?", Answer::AVAILABLE).where("users.username=?", username)
    unless (tasks_done_ids.empty?)
      where("#{self.table_name}.id not in (?)", tasks_done_ids)
    end
  }



  def done_by?(user)
    self.answers.where("answers.user_id=?",user).count!=0
  end

  def completion_ratio
    completed, size=self.completion
    completed.to_f/size.to_f
  end

  def completion
    completed=self.answers.answered.count
    size=self.answers.count
    [completed, size]
  end

end
