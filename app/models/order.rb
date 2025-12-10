class Order < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error
  
  enum :status, {
    created: 0,
    success: 1,
    cancelled: 2
  }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  
  scope :pending, -> { where(status: :created) }
  scope :completed, -> { where(status: :success) }
  scope :refunded, -> { where(status: :cancelled) }
  
  def can_complete?
    created? && user.account.sufficient_balance?(amount)
  end
  
  def can_cancel?
    success?
  end
  
  def debit_transaction
    transactions.find_by(transaction_type: :debit)
  end
  
  class InvalidTransitionError < StandardError; end
  class InsufficientFundsError < StandardError; end
end
