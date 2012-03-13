class AddFt < ActiveRecord::Migration
  def up
    change_table :projects do |t|
      t.string :ft_id
    end
  end

  def down
  end
end
