class TaskIndexer

  include Sidekiq::Worker

  def index(ft_id)

      i=0
      Task.transaction do
        FtDao.instance.import(self.input_ft, 100000) do |task_id|
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

end