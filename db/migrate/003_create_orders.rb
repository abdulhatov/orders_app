# db/migrate/003_create_orders.rb
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.integer :status, default: 0, null: false  # enum: created, success, cancelled
      t.string :description
      
      t.timestamps
    end
    
    add_index :orders, :status
    add_index :orders, [:user_id, :status]
  end
end
