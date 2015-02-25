class AddOauth2AccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :oauth2_access_token, :string, limit: 300
    add_column :users, :headline, :string
  end
end
