class AddTaskColumns < ActiveRecord::Migration
  def up
    	change_table :projects do |t|
	      t.integer  :lat_res, :default=>1
        t.integer  :lng_res,:default=>1
        t.integer  :redundancy,:default=>3
    	end
  end

  def down
  end
end
