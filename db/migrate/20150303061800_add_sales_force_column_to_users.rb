class AddSalesForceColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :oauth_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :instance_url, :string
  end
end
