# app/services/order_service.rb
#
# Сервис для управления заказами
# Инкапсулирует всю бизнес-логику переходов статусов и работы с транзакциями
#
class OrderService
  attr_reader :order, :errors

  def initialize(order)
    @order = order
    @errors = []
  end

  # Создание нового заказа
  # @param user [User] - пользователь
  # @param amount [Decimal] - сумма заказа
  # @param description [String] - описание
  # @return [Order, nil]
  def self.create(user:, amount:, description: nil)
    order = user.orders.build(
      amount: amount,
      description: description,
      status: :created
    )
    
    if order.save
      order
    else
      nil
    end
  end

  # Перевод заказа в статус "успешный"
  # Списывает деньги со счёта пользователя
  # @return [Boolean]
  def complete!
    return add_error("Заказ уже завершён") if order.success?
    return add_error("Заказ отменён") if order.cancelled?
    return add_error("Заказ должен быть в статусе 'created'") unless order.created?
    
    account = order.user.account
    return add_error("Недостаточно средств на счёте") unless account.sufficient_balance?(order.amount)
    
    ActiveRecord::Base.transaction do
      # Списываем деньги со счёта
      account.debit!(order.amount, order: order)
      
      # Меняем статус заказа
      order.success!
      
      true
    end
  rescue Account::InsufficientFundsError => e
    add_error(e.message)
  rescue ActiveRecord::RecordInvalid => e
    add_error("Ошибка сохранения: #{e.message}")
  rescue => e
    add_error("Неизвестная ошибка: #{e.message}")
  end

  # Отмена успешного заказа
  # Сторнирует транзакцию и возвращает деньги на счёт
  # @return [Boolean]
  def cancel!
    return add_error("Заказ уже отменён") if order.cancelled?
    return add_error("Можно отменить только успешный заказ") unless order.success?
    
    debit_transaction = order.debit_transaction
    return add_error("Транзакция списания не найдена") unless debit_transaction
    return add_error("Транзакция уже сторнирована") if debit_transaction.reversed?
    
    account = order.user.account
    
    ActiveRecord::Base.transaction do
      # Возвращаем деньги на счёт (сторнирование)
      account.credit!(
        order.amount,
        order: order,
        reversed_transaction: debit_transaction
      )
      
      # Меняем статус заказа
      order.cancelled!
      
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    add_error("Ошибка сохранения: #{e.message}")
  rescue => e
    add_error("Неизвестная ошибка: #{e.message}")
  end

  private

  def add_error(message)
    @errors << message
    false
  end
end
