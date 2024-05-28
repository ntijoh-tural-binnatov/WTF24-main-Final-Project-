require 'sqlite3'
require 'bcrypt'

def db
  if @db.nil?
    @db = SQLite3::Database.new('./db/db.sqlite')
    @db.results_as_hash = true
  end
  @db
end

def drop_tables
  db.execute('DROP TABLE IF EXISTS products')
  db.execute('DROP TABLE IF EXISTS reviews')
  db.execute('DROP TABLE IF EXISTS product_tags')
  db.execute('DROP TABLE IF EXISTS tags')
  db.execute('DROP TABLE IF EXISTS user_reviews')
  db.execute('DROP TABLE IF EXISTS users_account')
  db.execute('DROP TABLE IF EXISTS product_reviews')
  db.execute('DROP TABLE IF EXISTS carts')  
  db.execute('DROP TABLE IF EXISTS cart_items')
  db.execute('DROP TABLE IF EXISTS orders')  # Ny rad för att ta bort orders-tabellen
  db.execute('DROP TABLE IF EXISTS order_items')  # Ny rad för att ta bort order_items-tabellen
end

def create_tables
  db.execute('CREATE TABLE "reviews" (
    "id" INTEGER,
    "review" TEXT NOT NULL,
    "rating" INTEGER,
    "username" TEXT,
    "user_id" INTEGER NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
  
  db.execute('CREATE TABLE "product_tags" (
    "product_id" INTEGER,
    "tag_id" INTEGER
  )')
  
  db.execute('CREATE TABLE "products" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "price" INTEGER,
    "image_path" TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
  
  db.execute('CREATE TABLE "tags" (
    "id" INTEGER,
    "tag_name" TEXT NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
  
  db.execute('CREATE TABLE "user_reviews" (
    "user_id" INTEGER,
    "review_id" INTEGER
  )')
  
  db.execute('CREATE TABLE "users_account" (
    "id" INTEGER,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "mail" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
  
  db.execute('CREATE TABLE "product_reviews" (
    "id" INTEGER,
    "product_id" INTEGER,
    "review_id" INTEGER,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
  
  db.execute('CREATE TABLE "carts" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )') 
  
  db.execute('CREATE TABLE "cart_items" (
    "id" INTEGER ,
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )') 
  
  db.execute('CREATE TABLE "orders" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "total_price" INTEGER NOT NULL,
    "created_at" TEXT DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')

  db.execute('CREATE TABLE "order_items" (
    "id" INTEGER,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY("id" AUTOINCREMENT)
  )')
end

def seed_tables
  tags = [
    {name: 'Shirts'},
    {name: 'Jackets'},
    {name: 'Pants'},
    {name: 'Shorts'},
    {name: 'Bag'},
    {name: 'Accessories'}
  ]   

  tags.each do |tag|
    db.execute('INSERT INTO tags (tag_name) VALUES (?)', tag[:name])
  end

  products = [
    {name: 'GAK-shirt', description: ' a soft, juicy and gorgeous blue t-shirt!', price: 199, image_path: 'img/product/Blue-shirt.jpg'},
    {name: 'GAK-jacket', description: 'a soft, juicy and gorgeous blue jacket!', price: 459, image_path: "img/product/Blue-jacket.jpg"}
  ]

  products.each do |product|
    db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?,?,?,?)', product[:name], product[:description], product[:price], product[:image_path])
  end

  users = [
    {username: 'admin', password: BCrypt::Password.create('adminpassword'), mail: 'admin@example.com', role: 'admin'},
    {username: 'guest', password: BCrypt::Password.create('guestpassword'), mail: 'guest@example.com', role: 'guest'}
  ]

  users.each do |user|
    db.execute('INSERT INTO users_account (username, password, mail, role) VALUES (?, ?, ?, ?)', user[:username], user[:password], user[:mail], user[:role])
  end

  orders = [
    {user_id: 1, total_price: 658.0},  # Exempel order för admin
    {user_id: 2, total_price: 199.0}   # Exempel order för guest
  ]

  orders.each do |order|
    db.execute('INSERT INTO orders (user_id, total_price) VALUES (?, ?)', order[:user_id], order[:total_price])
  end

  # Seed order_items
  order_items = [
    {order_id: 1, product_id: 1, quantity: 1, price: 199.0},  # Exempel order_item för admin
    {order_id: 1, product_id: 2, quantity: 1, price: 459.0},
    {order_id: 2, product_id: 1, quantity: 1, price: 199.0}   # Exempel order_item för guest
  ]

  order_items.each do |order_item|
    db.execute('INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)', order_item[:order_id], order_item[:product_id], order_item[:quantity], order_item[:price])
  end
end



end

drop_tables
create_tables
seed_tables
