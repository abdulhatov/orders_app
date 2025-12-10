# app/models/account.rb
class Account < ApplicationRecord
  # Связи
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error
  
  # Валидации
  validates :balance, presence: true, numericality: true
  validates :currency, presence: true
  validates :user_id, uniqueness: true
  
  # Проверка достаточности средств
  def sufficient_balance?(amount)
    balance >= amount
  end
  
  # Списание средств (атомарная операция)
  def debit!(amount, order:)
    with_lock do
      raise InsufficientFundsError, "Недостаточно средств" unless sufficient_balance?(amount)
      
      balance_before = balance
      new_balance = balance - amount
      
      update!(balance: new_balance)
      
      transactions.create!(
        order: order,
        amount: -amount,
        transaction_type: :debit,
        balance_before: balance_before,
        balance_after: new_balance
      )
    end
  end
  
  # Пополнение средств (атомарная операция)
  def credit!(amount, order:, reversed_transaction: nil)
    with_lock do
      balance_before = balance
      new_balance = balance + amount
      
      update!(balance: new_balance)
      
      transactions.create!(
        order: order,
        amount: amount,
        transaction_type: reversed_transaction ? :reversal : :credit,
        balance_before: balance_before,
        balance_after: new_balance,
        reversed_transaction: reversed_transaction
      )
    end
  end
  
  # Кастомная ошибка
  class InsufficientFundsError < StandardError; end
end
