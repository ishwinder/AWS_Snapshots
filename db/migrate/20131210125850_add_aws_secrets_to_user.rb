class AddAwsSecretsToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_key, :string
    add_column :users, :secret_token, :string
  end
end
