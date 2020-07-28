class CreateChatbots < ActiveRecord::Migration[6.0]
  def change
    create_table :chatbots do |t|
      t.string :username
      t.string :description
      t.references :user

      t.timestamps
    end
  end
end
