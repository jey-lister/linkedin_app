class CreateDetailedProfiles < ActiveRecord::Migration
  def change
    create_table :detailed_profiles do |t|
      t.text :info
      t.integer :user_id, index: true

      t.timestamps null: false
    end
  end
end
