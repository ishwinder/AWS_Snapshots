class AddDefaultRegionToUser < ActiveRecord::Migration
  def change
    add_column :users, :default_region, :string, default: 'us-east-1'
  end
end
