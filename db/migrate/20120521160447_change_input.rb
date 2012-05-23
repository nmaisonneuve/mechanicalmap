class ChangeInput < ActiveRecord::Migration
  def up
    change_column(:tasks, :input, :integer)
  end

  def down
  end
end
