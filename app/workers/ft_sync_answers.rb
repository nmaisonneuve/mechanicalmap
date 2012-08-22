class FtSyncAnswers

  include Sidekiq::Worker

  def perform(app_id)
    if (app_id.nil?)
      raise ArgumentError.new("no application given to sync")
    end
    app=App.find(app_id)
    app.sync_answers()
  end
end