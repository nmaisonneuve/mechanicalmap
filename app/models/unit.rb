class Unit < ActiveRecord::Base

  AVAILABLE=0
  PENDING=1
  COMPLETED=2

  belongs_to :user
  belongs_to :task

  scope :available, where(:state=>AVAILABLE)
  scope :answered, where("state!=?",AVAILABLE)


  #any kind of answer e.g string , json
  # interpreted by the related aggregator
  attr_accessible :state, :answer, :user, :ft_sync

  def done_by?(user)
    self.user!=user
  end

end
