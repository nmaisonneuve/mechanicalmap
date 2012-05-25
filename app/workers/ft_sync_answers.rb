class FtSyncAnswers
  MAX_ANSWERS=10000

  include Sidekiq::Worker

  def perform()
    App.all.each { |app|
      answers=app.answers.answered.where(:ft_sync => false)
      if (answers.size>0)
        puts "#{answers.size} answers to synchronize"
        FtDao.instance.sync_answers(answers)
      end
      }
  end
end