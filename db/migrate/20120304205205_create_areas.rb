class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.references :project
      t.float :lat_sw
      t.float :lng_sw
      t.float :lat_ne
      t.float :lng_ne
      t.timestamps
    end
    add_index :areas, :project_id
  end
end
