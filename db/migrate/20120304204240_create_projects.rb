class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.float :lat_sw
      t.float :lng_sw
      t.float :lat_ne
      t.float :lng_ne
      t.timestamps
    end
  end
end
