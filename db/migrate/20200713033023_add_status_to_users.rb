class AddStatusToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :string, after: :coin_list
  end
end
