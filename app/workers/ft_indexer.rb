class FtIndexer

  MAX_ANSWERS=10000

  include Sidekiq::Worker

  def perform(app,redundancy=1)
    i=0
    Task.transaction do
      FtDao.instance.import(ft_id, 100000) do |task_id|
        task=Task.create(:input => task_id, :app_id => app.id)
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