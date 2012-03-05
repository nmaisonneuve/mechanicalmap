class Task < ActiveRecord::Base

  AVAILABLE=0
  IN_PROGRESS=1
  COMPLETED=2

  belongs_to :user
  scope :open, where(:state=>AVAILABLE)
  scope :pending, where(:state=> IN_PROGRESS)
  scope :completed, where(:state=>COMPLETED)

  attr_accessible  :state

  belongs_to :area



end
