#Added a number of additional columns to checkouts to track transaction/verification response
class AddFieldsToCheckouts < ActiveRecord::Migration[5.2]
  def change
    add_column :checkouts, :transaction_id, :string
    add_column :checkouts, :verification_id, :string
    add_column :checkouts, :transaction_success, :boolean
    add_column :checkouts, :verification_success, :boolean
    add_column :checkouts, :transaction_result, :string
    add_column :checkouts, :verification_result, :string
  end
end
