class CreateOccurences < ActiveRecord::Migration
  def change
    create_table :occurences do |t|
      t.datetime :time
      t.references :schedule, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
