class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.integer :telegram_id
      t.string :step
      t.string :coin_list, array: true

      t.timestamps
    end
  end
end
