# Установка
1. Требования

    Ruby 3.2+
    Rails 7.0+ или 8.0+
    SQLite3 (или PostgreSQL)

2. Проверить версии

    bashruby -v    # должно быть 3.2.0 или выше
    rails -v   # должно быть 7.0 или выше
3. Установить Ruby (если нет)

    macOS:
    bashbrew install rbenv ruby-build
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc
    source ~/.zshrc
    rbenv install 3.2.0
    rbenv global 3.2.0
    Ubuntu/Debian:
    bashsudo apt update
    sudo apt install ruby-full

4. Установить Rails
    bashgem install rails


5. Клон проекта
    git clone https://github.com/abdulhatov/orders_app.git
    cd orders_app

# Тестирование в Rails Console

cd orders_app
rails console

### Тест 1: Создание пользователя
user = User.create!(email: 'ivan3@example.com', name: 'Иван Петров')

# Проверить что счёт создан
user.account

# Пополнить счёт (для теста)
user.account.update!(balance: 1000)
user.account.balance


# Тест 2: Создание и оплата заказа

Создать заказ

order = user.orders.create!(
  amount: 250,
  description: 'Покупка билета',
  status: :created
)

order.status

Оплатить заказ через сервис

service = OrderService.new(order)
service.complete!

Проверить статус
order.reload.status

Проверить баланс (1000 - 250 = 750)
user.account.reload.balance

Посмотреть транзакцию
   order.transactions.last
=> #<Transaction amount: -250.0, transaction_type: "debit">


# Тест 3: Отмена заказа (сторнирование)

Отменить заказ
service.cancel!

Проверить статус
order.reload.status

Проверить баланс (деньги вернулись: 750 + 250 = 1000)
user.account.reload.balance

Посмотреть все транзакции
order.transactions.each do |t|
  puts "#{t.transaction_type}: #{t.amount} (#{t.balance_before} → #{t.balance_after})"
end

# Тест 4: Ошибка — недостаточно средств
Создать бедного пользователя
poor_user = User.create!(email: 'poor@example.com', name: 'Бедный')
poor_user.account.balance
=> 0.0

Попытка создать и оплатить заказ
big_order = poor_user.orders.create!(amount: 500, status: :created)
service = OrderService.new(big_order)
service.complete!
=> false

Посмотреть ошибку
service.errors
=> ["Недостаточно средств на счёте"]

Статус не изменился
big_order.reload.status
=> "created"

# Тест 5: Ошибка — нельзя отменить неоплаченный заказ
Создать заказ
order = user.orders.create!(amount: 100, status: :created)

Попытка отменить без оплаты
service = OrderService.new(order)
service.cancel!
=> false

service.errors
=> ["Можно отменить только успешный заказ"]


