module Order
    def self.create(user_id, total_price)
      db.execute('INSERT INTO orders (user_id, total_price) VALUES (?, ?)', user_id, total_price)
    end
  
    def self.find(id)
      db.execute('SELECT * FROM orders WHERE id = ?', id).first
    end
  
    def self.all
      db.execute('SELECT * FROM orders')
    end
  
    def self.find_by_user(user_id)
      db.execute('SELECT * FROM orders WHERE user_id = ?', user_id)
    end
  
    def self.add_item(order_id, product_id, quantity, price)
      db.execute('INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)', order_id, product_id, quantity, price)
    end
  
    def self.items(order_id)
      db.execute('SELECT * FROM order_items WHERE order_id = ?', order_id)
    end
  
    def self.delete(id)
      db.execute('DELETE FROM order_items WHERE order_id = ?', id)
      db.execute('DELETE FROM orders WHERE id = ?', id)
    end
    
    def self.db
        if @db.nil?
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        @db
    end
end