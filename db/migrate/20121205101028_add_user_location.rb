class AddUserLocation < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :city, :string
  end
end
