class FtIndexer

  include Sidekiq::Worker

  def perform(app_id)
    App.find(app_id).index_tasks
  end

end