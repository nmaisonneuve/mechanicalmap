class AddResolution < ActiveRecord::Migration
  def up
    change_column(:projects, :lat_res, :float, :default=>1.0)
    change_column(:projects, :lng_res, :float, :default=>1.0)
  end

  def down
  end
end
