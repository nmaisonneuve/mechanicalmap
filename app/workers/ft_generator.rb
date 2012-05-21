class FtGenerator

  include Sidekiq::Worker

  def perform(schema)

    self.output_ft=FtDao.instance.create_table("Answers of #{self.name}", schema)
    self.save

    # set permission exportable
    FtDao.instance.set_exportable(self.output_ft)
    FtDao.instance.change_ownership(self.output_ft, user_email)
  end




end