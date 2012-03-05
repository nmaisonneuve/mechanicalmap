class AddUser < ActiveRecord::Migration
  def up
    change_table :tasks do |t|
      t.references :user
    end
  end

  def down
  end
end
