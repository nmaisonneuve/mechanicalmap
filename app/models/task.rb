class Task < ActiveRecord::Base

  AVAILABLE=0
  IN_PROGRESS=1
  COMPLETED=2

  belongs_to :user
  scope :open, where(:state=>AVAILABLE)
  scope :pending, where(:state=> IN_PROGRESS)
  scope :completed, where(:state=>COMPLETED)

  #any kind of answer e.g string , json
  # interpreted by the related aggregator
  attr_accessible  :state, :answer

  belongs_to :area


  def self.aggregate(tasks)
    yes=0
    tasks.each { |task|
     yes=yes+1 if (task.answer.to_i==1)
    }
    no=tasks.size-yes
    decision= (yes>no)? 1 : 0
    aggregate=AggregateInfo.create(:decision=>decision, :yes=>yes, :no=>no)
  end

end
