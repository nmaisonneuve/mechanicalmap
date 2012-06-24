class FtSyncAnswers

  include Sidekiq::Worker

  def perform()
    App.all.each { |app|
      app.synch_answers
    }
  end
end