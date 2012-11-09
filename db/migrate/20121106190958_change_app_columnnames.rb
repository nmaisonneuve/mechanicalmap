class ChangeAppColumnnames < ActiveRecord::Migration

  def up
		change_table :apps do |t|
		  t.rename :input_ft,  :challenges_table_url
		  t.rename :output_ft, :answers_table_url
		  t.rename :gist_id, :gist_url
		end

		App.all.each { |app|
			app.challenges_table_url = "https://www.google.com/fusiontables/DataSource?docid=#{app.challenges_table_url}" unless app.challenges_table_url.nil?
			app.answers_table_url = "https://www.google.com/fusiontables/DataSource?docid=#{app.challenges_table_url}" unless app.answers_table_url.nil?
			app.gist_url = "https://gist.github.com/#{app.gist_url}" unless app.gist_url.nil?
		}
	end

  def down
  end

end
