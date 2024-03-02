require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS cart_items')
    db.execute('DROP TABLE IF EXISTS categories')
    db.execute('DROP TABLE IF EXISTS order')
    db.execute('DROP TABLE IF EXISTS payments')
    db.execute('DROP TABLE IF EXISTS products')
    db.execute('DROP TABLE IF EXISTS review')
    db.execute('DROP TABLE IF EXISTS users')
end

def create_tables


    db.execute('CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        name TEXT NOT NULL
    )')


    db.execute('CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
    )')

    db.execute('CREATE TABLE order(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_item INTEGER NOT NULL,
        total_cost INTEGER NOT NULL
    )')

    db.execute('CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        payment_type TEXT NOT NULL
    )')

    db.execute('CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER,
        description TEXT NOT NULL,
        rating INTEGER
    )')

    db.execute('CREATE TABLE review(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description INTEGER NOT NULL,
        name TEXT NOT NULL
    )')

    db.execute('CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
    )')


def seed_tables

    products = [
        {name: 'GAK t-shirt', price: '200 SEK' , description: 'a soft, juicy and gorgeous blue t-shirt!', rating: '7/10'}
    ]

    products.each do |product|
        db.execute('INSERT INTO products (name, price, description, rating) VALUES (?,?,?,?)', product[:name], product[:price], product[:description], product[:rating])
    end


    categories = [{name: 'T-shirts'}]

    categories.each do |category|
        db.execute('INSERT INTO categories (name) VALUES (?)', category[:name])
    end



end

drop_tables
create_tables
seed_tables