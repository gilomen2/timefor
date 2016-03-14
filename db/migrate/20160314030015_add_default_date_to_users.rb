class AddDefaultDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_date, :date
  end
end
