# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :complete, :cancel]

  # GET /orders
  def index
    @orders = current_user.orders.order(created_at: :desc)
    render json: @orders
  end

  # GET /orders/:id
  def show
    render json: order_json(@order)
  end

  # POST /orders
  def create
    order = OrderService.create(
      user: current_user,
      amount: order_params[:amount],
      description: order_params[:description]
    )
    
    if order
      render json: order_json(order), status: :created
    else
      render json: { error: "Не удалось создать заказ" }, status: :unprocessable_entity
    end
  end

  # POST /orders/:id/complete
  # Перевод заказа в статус "успешный"
  def complete
    service = OrderService.new(@order)
    
    if service.complete!
      render json: {
        order: order_json(@order.reload),
        message: "Заказ успешно оплачен",
        new_balance: current_user.account.balance
      }
    else
      render json: { 
        errors: service.errors,
        order: order_json(@order)
      }, status: :unprocessable_entity
    end
  end

  # POST /orders/:id/cancel
  # Отмена успешного заказа (сторнирование)
  def cancel
    service = OrderService.new(@order)
    
    if service.cancel!
      render json: {
        order: order_json(@order.reload),
        message: "Заказ отменён, средства возвращены",
        new_balance: current_user.account.balance
      }
    else
      render json: { 
        errors: service.errors,
        order: order_json(@order)
      }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:amount, :description)
  end

  def order_json(order)
    {
      id: order.id,
      amount: order.amount,
      status: order.status,
      description: order.description,
      created_at: order.created_at,
      updated_at: order.updated_at,
      transactions: order.transactions.map do |t|
        {
          id: t.id,
          type: t.transaction_type,
          amount: t.amount,
          balance_before: t.balance_before,
          balance_after: t.balance_after,
          created_at: t.created_at
        }
      end
    }
  end
end
