class AddScriptColumns < ActiveRecord::Migration
  def up
    change_table :projects do |t|
	      t.text  :script
        t.string  :script_url
        t.text  :ui_template
    	end
  end

  def down
  end
end
