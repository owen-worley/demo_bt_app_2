class CreateCheckouts < ActiveRecord::Migration[5.2]
  def change
    create_table :checkouts do |t|
      t.string :email
      t.string :first_name
      t.string :customer_id
      t.numeric :postal_code
      t.numeric :amount
      t.string :card_type
      t.references :cart, foreign_key: true

      t.timestamps
    end
  end
end
