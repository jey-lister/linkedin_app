class AddColumnConnectionsToDetailedProfile < ActiveRecord::Migration
  def change
    add_column :detailed_profiles, :connections, :text
  end
end
