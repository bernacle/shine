class AddSettingsToUser < ActiveRecord::Migration
  def up
    enable_extension :hstore
    add_column :users, :settings, :hstore, defalut: {}
  end
  def down
    remove_column :users, :settings
    disable_extension :hstore
  end
end
