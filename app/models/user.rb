# app/models/user.rb
class User < ApplicationRecord
  # Связи
  has_one :account, dependent: :destroy
  has_many :orders, dependent: :destroy
  
  # Валидации
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  
  # Колбэки
  after_create :create_account!
  
  # Делегирование для удобства
  delegate :balance, to: :account, prefix: true, allow_nil: true
  
  private
  
  def create_account!
    create_account(balance: 0)
  end
end
