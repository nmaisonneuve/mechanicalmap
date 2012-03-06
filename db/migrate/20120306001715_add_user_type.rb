class AddUserType < ActiveRecord::Migration
  def up
change_table :users do |t|
      t.boolean :anonymous, :default=>false
    end
  end

  def down
  end
end
