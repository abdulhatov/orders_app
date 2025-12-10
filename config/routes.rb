# config/routes.rb
Rails.application.routes.draw do
  resources :orders, only: [:index, :show, :create] do
    member do
      post :complete  # POST /orders/:id/complete
      post :cancel    # POST /orders/:id/cancel
    end
  end
  
  # Дополнительные маршруты для счёта
  resource :account, only: [:show] do
    get :transactions  # GET /account/transactions
  end
end
