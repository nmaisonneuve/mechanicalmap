class Answer < ActiveRecord::Base

  STATE={
    :AVAILABLE=>0,
    :COMPLETED=>2
  }

  belongs_to :user,  :touch => true
  belongs_to :task

  scope :available, where(:state => STATE[:AVAILABLE])
  scope :not_available, where("state!=?", STATE[:AVAILABLE])
  scope :answered, where(:state => STATE[:COMPLETED]) 
  scope :to_synchronize, answered.where(:ft_sync=>false)
  #any kind of answer e.g string , json
  # interpreted by the related aggregator
  attr_accessible :state, :answer, :user, :ft_sync

  def done_by?(user)
    self.user!=user
  end

  # if some fields are not present
  # we enriched the answers with default values
  def input_from_form(rows)
    rows.each { |row|
      row["task_id"]=self.task.input_task_id if row["task_id"].blank?
      row["user_id"]=self.user.username if row["user_id"].blank?
      row["created_at"]=DateTime.now if row["created_at"].blank?
    }
    self.answer=rows.to_json
  end
  
  def as_json(options={})
    {
      :user=>(self.user.nil?)? nil : self.user.username,
      :updated_at=>self.updated_at,
      :content=> self.answer,
      :state=> STATE.invert[state]
    }
  end  
end
