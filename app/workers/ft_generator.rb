class FtGenerator

  include Sidekiq::Worker
  
  def perform(app_id, schema, user_email)
     app = App.find(app_id)
     app.output_ft = FtDao.instance.create_table_smart("Table for #{app.name}", schema,user_email)
  end

end