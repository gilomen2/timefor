class AddTimezoneToFrequency < ActiveRecord::Migration
  def change
  	add_column :frequencies, :timezone, :string
  end
end
