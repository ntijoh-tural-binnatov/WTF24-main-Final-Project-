module Product 
    def self.all 
      db.execute('SELECT * FROM products')
    end
  
    def self.find(id) 
      db.execute('SELECT * FROM products WHERE id = ?', id).first
    end
  
    def self.products_with_tag(tag) 
      db.execute('SELECT products.id, products.name, products.description, products.price, products.image_path FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id WHERE tags.tag_name = ?', tag)
    end
  
    def self.create_product(name, description, price, image_path) 
      db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?)', name, description, price, image_path)
    end
  
    def self.delete_product(id) 
      db.execute('DELETE FROM products WHERE id = ?', id)
    end

    def self.product_from_products
      db.execute('SELECT products.* FROM products
            INNER JOIN product_tags ON products.id = product_tags.product_id
            WHERE product_tags.tag_id = ?', tag['id'])
    end
  
    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        @db
    end
end
  