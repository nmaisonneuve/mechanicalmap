class FtGenerator

  include Sidekiq::Worker

  def perform(app_id, schema, user_email)
     app=App.find(app_id)
     app.output_ft=FtDao.instance.create_table("Answers of #{app.name}", schema)
     app.save

    # set permission exportable
    FtDao.instance.set_exportable(app.output_ft)
    FtDao.instance.change_ownership(app.output_ft, user_email)
  end




end