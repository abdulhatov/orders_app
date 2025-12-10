class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :order
  belongs_to :reversed_transaction, class_name: 'Transaction', optional: true
  has_one :reversal, class_name: 'Transaction', foreign_key: :reversed_transaction_id
  
  enum :transaction_type, {
    debit: 0,
    credit: 1,
    reversal: 2
  }
  
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true
  validates :balance_before, presence: true, numericality: true
  validates :balance_after, presence: true, numericality: true
  
  def reversed?
    reversal.present?
  end
  
  def can_reverse?
    debit? && !reversed?
  end
end
