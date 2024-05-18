require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS products')
    db.execute('DROP TABLE IF EXISTS reviews')
    db.execute('DROP TABLE IF EXISTS product_tags')
    db.execute('DROP TABLE IF EXISTS tags')
    db.execute('DROP TABLE IF EXISTS user_reviews')
    db.execute('DROP TABLE IF EXISTS users_account')
    db.execute('DROP TABLE IF EXISTS product_reviews')
end

def create_tables

    db.execute('CREATE TABLE "reviews" (
        "id"	INTEGER,
        "review"	TEXT NOT NULL,
        "rating"	INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.execute('CREATE TABLE "product_tags" (
        "product_id"	INTEGER,
        "tag_id"	INTEGER
    )')
    
    db.execute('CREATE TABLE "products" (
        "id"	INTEGER,
        "name"	TEXT NOT NULL,
        "description"	TEXT,
        "price"	INTEGER,
        "image_path"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.execute('CREATE TABLE "tags" (
        "id"	INTEGER,
        "tag_name"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.execute('CREATE TABLE "user_reviews" (
        "user_id"	INTEGER,
        "review_id"	INTEGER
    )')
    
    db.execute('CREATE TABLE "users_account" (
        "id"	INTEGER,
        "username"	TEXT NOT NULL,
        "password"	TEXT NOT NULL,
        "mail" TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.execute('CREATE TABLE "product_reviews" (
        "id"	INTEGER,
        "product_id"	INTEGER,
        "review_id"	INTEGER,
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
end

drop_tables
create_tables
seed_tables