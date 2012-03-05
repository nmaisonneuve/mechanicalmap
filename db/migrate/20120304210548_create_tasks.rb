class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :area
      t.integer :state
      t.timestamps
    end
    add_index :tasks, :area_id
  end
end
