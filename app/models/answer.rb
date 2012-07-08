class Answer < ActiveRecord::Base

  AVAILABLE=0
  COMPLETED=2

  belongs_to :user
  belongs_to :task

  scope :available, where(:state => AVAILABLE)
  scope :not_available, where("state!=?", AVAILABLE)
  scope :answered, where(:state => COMPLETED)

  #any kind of answer e.g string , json
  # interpreted by the related aggregator
  attr_accessible :state, :content, :user, :ft_sync

  def done_by?(user)
    self.user!=user
  end

  # if they are not present
  # we enriched the answer by common info
  def input_from_form(form_input)
    answer=ActiveSupport::JSON.decode(form_input)
    answer.each { |row|
      row["task_id"]=self.task.id if row["task_id"].blank?
      row["user_id"]=self.user.username if row["user_id"].blank?
      row["created_at"]=DateTime.now if row["created_at"].blank?
    }
    self.answer=answer.to_json
  end

end
