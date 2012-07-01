class FtSyncAnswers

  include Sidekiq::Worker

  def perform()
  	
    App.all.each { |app|
    begin 
      app.synch_answers
      rescue e
      	raise Exception.new("Error sync answer for #{app.name} \n errors: #{e.backtrace}")
	end
    }

  end
end