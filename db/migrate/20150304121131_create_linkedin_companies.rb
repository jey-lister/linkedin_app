class CreateLinkedinCompanies < ActiveRecord::Migration
  def change
    create_table :linkedin_companies do |t|
      t.integer :company_id, index: true
      t.text :profile
      t.timestamps null: false
    end
  end
end
