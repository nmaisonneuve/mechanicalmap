class AddCustomMap < ActiveRecord::Migration
  def up
	change_table :projects do |t|
	      t.string  :wms_map, :default=>nil
    	end
  end

  def down
  end
end
