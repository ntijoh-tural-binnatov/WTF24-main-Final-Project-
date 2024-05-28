module Cart
    def self.find_or_create(user_id)
      db.execute('SELECT * FROM carts WHERE user_id = ?', user_id).first || create(user_id)
    end
  
    def self.create(user_id)
      db.execute('INSERT INTO carts (user_id) VALUES (?)', user_id)
      db.execute('SELECT * FROM carts WHERE user_id = ?', user_id).first
    end
  
    def self.add_item(cart_id, product_id, quantity)
      db.execute('INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)', cart_id, product_id, quantity)
    end
  
    def self.remove_item(item_id)
      db.execute('DELETE FROM cart_items WHERE id = ?', params[:id])
    end
  
    def self.update_item_quantity(item_id, new_quantity)
      if new_quantity > 0
        db.execute('UPDATE cart_items SET quantity = ? WHERE id = ?', new_quantity, params[:id])
      else
        remove_item(item_id)
      end
    end
  
    def self.get_items(cart_id)
      db.execute('SELECT * FROM cart_items WHERE cart_id = ?', cart_id)
    end
  
    def self.total_price(cart_id)
      items = get_items(cart_id)
      items.reduce(0) { |sum, item| sum + (item['price'] * item['quantity']) }
    end
    
    def self.db
        if @db.nil?
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        @db
    end
end
  