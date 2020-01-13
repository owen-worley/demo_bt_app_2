#Cart database rows only track the submitted amount
class CreateCarts < ActiveRecord::Migration[5.2]
  def change
    create_table :carts do |t|
      t.numeric :amount
      t.timestamps
    end
  end
end
