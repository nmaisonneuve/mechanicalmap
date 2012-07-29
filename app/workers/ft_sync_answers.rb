class FtSyncAnswers

  include Sidekiq::Worker

  def perform(app_id)
    App.find(app_id).synch_answers
  end
end