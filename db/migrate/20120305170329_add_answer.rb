class AddAnswer < ActiveRecord::Migration
  def up
    change_table :tasks do |t|
      t.text :answer
    end
  end

  def down
  end
end
