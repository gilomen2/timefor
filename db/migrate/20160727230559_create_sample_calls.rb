class CreateSampleCalls < ActiveRecord::Migration
  def change
    create_table :sample_calls do |t|
      t.string :name
      t.string :phone

      t.timestamps null: false
    end
  end
end
