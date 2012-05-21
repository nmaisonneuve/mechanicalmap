class FtWorker

  MAX_ANSWERS=10000

  include Sidekiq::Worker

  def generate_output(schema)

    self.output_ft=FtDao.instance.create_table("Answers of #{self.name}", schema)
    self.save

    # set permission exportable
    FtDao.instance.set_exportable(self.output_ft)
    FtDao.instance.change_ownership(self.output_ft, user_email)
  end

  def index_task(ft_id,redundancy=1)

      i=0
      Task.transaction do
        FtDao.instance.import(ft_id, 100000) do |task_id|
          task=Task.create(:input => task_id, :app_id => self.id)
          # just one answer for the moment
          redundancy.times do
            task.answers<<Answer.create!(:state => Answer::AVAILABLE)
            i=i+1
          end
          task.save
          break if (i> MAX_ANSWERS)
        end
      end
    end


end