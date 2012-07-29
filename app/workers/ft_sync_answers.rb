class FtSyncAnswers

  include Sidekiq::Worker

  def perform(app_id)
   if (app_id.nil?)
        raise ArgumentError.new("no application given to sync")
      end
    App.find(app_id).synch_answers()
  rescue
  end
end