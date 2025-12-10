# db/migrate/004_create_transactions.rb
class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false  # + пополнение, - списание
      t.integer :transaction_type, default: 0, null: false     # enum: debit, credit, reversal
      t.decimal :balance_before, precision: 15, scale: 2, null: false
      t.decimal :balance_after, precision: 15, scale: 2, null: false
      t.references :reversed_transaction, foreign_key: { to_table: :transactions }, null: true
      
      t.timestamps
    end
    
    add_index :transactions, :transaction_type
    add_index :transactions, [:account_id, :created_at]
  end
end
