class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false
      t.string :currency, default: 'RUB', null: false
      
      t.timestamps
    end
  end
end
