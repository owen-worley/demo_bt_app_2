class AddLastNameToCheckouts < ActiveRecord::Migration[5.2]
  def change
    add_column :checkouts, :last_name, :string
  end
end
