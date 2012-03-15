class AddUsername < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :username
    end
  end

  def down
  end
end
