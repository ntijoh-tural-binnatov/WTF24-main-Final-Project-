require 'sinatra/base'
require 'sqlite3'
require 'bcrypt'
require 'securerandom'

require_relative 'models/user'
require_relative 'models/review'
require_relative 'models/tag'
require_relative 'models/cart'
require_relative 'models/product'




def get_username(user_id)
    user = db.execute('SELECT username FROM users_account WHERE id = ?', user_id).first

    if user
        return user['username']
    else
        return 'Unknown'
    end
end

class App < Sinatra::Base
    
    enable :sessions

    def db
        if @db.nil?
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        @db
    end

    helpers do 
        def html_escape(text)
            Rack::Utils.escape_html(text)
        end

        def admin?
            session[:role] == 'admin'
        end

        def guest?
            session[:role] == 'guest'
        end

        def current_user
            session[:user_id]
        end

        def find_or_create_cart(user_id)
            cart = db.execute('SELECT * FROM carts WHERE user_id = ?', user_id).first || create(user_id)

            if cart.nil?
                Cart.create(user_id)
                cart = Cart.create(user_id)
            end
            cart
        end
    end

    get '/user/login' do
        erb :'user/login_account'
    end

    get '/user/login/admin' do
        erb :'user/login_admin'
    end

    get '/user/login/guest' do
        erb :'user/login_guest'
    end

    get '/user/register' do
        erb :'user/register_account'
    end

    post '/user/register' do
        username = params["username"]
        mail = params["mail"]
        password = params["password"]
        role = params["role"]
        hashed_password = BCrypt::Password.create(password)
        db.execute('INSERT INTO users_account (username, password, mail, role) VALUES (?,?,?,?)', username, hashed_password, mail, role)

        if role == 'admin'
            redirect '/user/login/admin'
        elsif role == 'guest'
            redirect '/user/login/guest'
        else
            redirect '/products/404'
        end
    end

    post '/user/login/admin' do
        username = params['username']
        cleartext_password = params['password']

        user = db.execute('SELECT * FROM users_account WHERE username = ? AND role = "admin"', params[:username]).first


        if user && BCrypt::Password.new(user['password']) == cleartext_password
            session[:user_id] = user['id']
            session[:username] = username
            session[:role] = user['role']
            redirect '/products'
        else
            redirect '/products/404'
        end
    end

    post '/user/login/guest' do
        username = params['username']
        cleartext_password = params['password']
      
        user = db.execute('SELECT * FROM users_account WHERE username = ? AND role = "guest"', params[:username]).first

      
        if user && BCrypt::Password.new(user['password']) == cleartext_password
            session[:user_id] = user['id']
            session[:username] = username
            session[:role] = user['role']
            redirect '/products'  
        else
            redirect '/user/login/guest' 
        end
    end
      
    get '/' do
        redirect '/products'
    end

    get '/products' do
        @products = Product.all
        @tags = Tag.all
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id')
        erb :'products/index'
    end

    get '/products/new' do
        if admin?
            @tags = Tag.all
            erb :'products/new'
        else
            redirect '/products'
        end
    end 

    get '/products/product/:id' do |id|
        @product = Product.find(id)
        @reviews = db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id WHERE products.id = ?', id)
        @product_tags = Tag.on_product(id)
        sum_ratings = 0
        värde = 0.0
        @reviews.each do |review|
            sum_ratings += review['rating'].to_i
            värde += 1
        end
        if värde == 0
            @rating = "Review this product!"
        else
            @rating = "#{(sum_ratings/värde).round(2)}/5" 
        end
        erb :'products/show'
    end

    get '/products/:id' do |id|
        @products = []
        tag = Tag.all_tags_where_tag_name(id)
        if tag
            tag_id = tag['id']
            product_tags = db.execute('SELECT * FROM product_tags WHERE tag_id = ?', tag_id)
            product_tags.each do |product_tag|
                product_id = product_tag['product_id']
                product = db.execute('SELECT * FROM products WHERE id = ?', product_id).first
                @products << product if product
            end
        else
            @error_message = "Tag not found: #{id}"
        end
        @tags = Tag.all
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id')
        erb :'products/index'
    end

    get '/products/:tag' do |tag_name|
        @tags = Tag.all
        tag = db.execute('SELECT * FROM tags WHERE tag_name = ?', tag_name).first
        
        if tag
            @products = Product.product_from_products(tag['id'])
        else
          @products = []
        end
        erb :'products/index'
    end
      
    
    post '/products/tags' do
        tag = params["tag"]
        if tag == 'all'
            redirect '/products'
        else
            redirect "/products/#{tag}"
        end
    end

    post '/products/create' do
        if admin?
            file = params[:file][:tempfile]
            file_name = SecureRandom.alphanumeric(16)
            file_path = "img/product/#{file_name}.jpg"
    
            File.open("public/#{file_path}", 'wb') do |f|
                f.write(file.read)
            end
    
            result = db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?) RETURNING *', params[:name], params[:description], params[:price], file_path).first
            tag_name = params[:tag]
            tag = db.execute('SELECT * FROM tags WHERE tag_name = ?', tag_name).first
            if tag
                db.execute('INSERT INTO product_tags (product_id, tag_id) VALUES (?, ?)', result["id"], tag["id"])
            end
            redirect '/products'
        end
    end
    
    
    get '/products/:id/delete' do |id|
        if admin?
            @product = Product.find(id)
            erb :'products/delete'
        else
            redirect '/products'
        end
    end

    post '/products/review/:id' do |id|
        user_id = session[:user_id]
      
        if user_id.nil?
          redirect '/user/login'
        else
          username = db.execute('SELECT username FROM users_account WHERE id = ?', user_id).first['username']
          review = params[:review]
          rating = params[:rating]
      
          result = db.execute('INSERT INTO reviews (rating, review, user_id) VALUES (?, ?, ?) RETURNING *', rating, review, user_id).first
          db.execute('INSERT INTO product_reviews (product_id, review_id) VALUES (?, ?)', id, result['id'])
          redirect_to = params['redirect_to']
          redirect redirect_to
        end
    end

    post '/products/:id/delete' do |id|
        if admin?
            product = Product.find(id)
            File.delete("public/#{product['image_path']}")
            Product.delete_product(id)
            redirect '/products'
        else
            redirect '/products'
        end
    end

    get '/reviews/:id/delete' do |id|
        @review = Review.find(id)
        erb :'reviews/delete'
    end

    post '/reviews/:id/delete' do |id|
        product_id = db.execute('SELECT * FROM product_reviews WHERE review_id = ?', id).first['product_id']
        db.execute('DELETE FROM product_reviews WHERE review_id = ?', id)
        db.execute('DELETE FROM reviews WHERE id = ?', id)
        redirect "/products/product/#{product_id}"
    end

    get '/cart' do
        if session[:user_id]
          @cart = db.execute('SELECT * FROM carts WHERE user_id = ?', session[:user_id]).first
          if @cart
            @cart_items = db.execute('SELECT cart_items.id, products.name, products.price, cart_items.quantity FROM cart_items INNER JOIN products ON cart_items.product_id = products.id WHERE cart_items.cart_id = ?', @cart['id'])
            @total_price = @cart_items.reduce(0) { |sum, item| sum + item['price'] * item['quantity'] }
          else
            @cart_items = []
            @total_price = 0
          end
          erb :'cart/show'
        else
          redirect '/user/login'
        end
      end
    
      post '/cart/add/:product_id' do
        if session[:user_id]
          product_id = params[:product_id].to_i
          quantity = params[:quantity].to_i
    
          cart = db.execute('SELECT * FROM carts WHERE user_id = ?', session[:user_id]).first
          if cart.nil?
            db.execute('INSERT INTO carts (user_id) VALUES (?)', session[:user_id])
            cart = db.execute('SELECT * FROM carts WHERE user_id = ?', session[:user_id]).first
          end
    
          cart_item = db.execute('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ?', cart['id'], product_id).first
          if cart_item
            db.execute('UPDATE cart_items SET quantity = quantity + ? WHERE id = ?', quantity, cart_item['id'])
          else
            db.execute('INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)', cart['id'], product_id, quantity)
          end
    
          redirect '/cart'
        else
          redirect '/user/login'
        end
      end
    
      post '/cart/item/:id/remove' do
        if session[:user_id]
          db.execute('DELETE FROM cart_items WHERE id = ?', params[:id])
          redirect '/cart'
        else
          redirect '/user/login'
        end
      end
    
      post '/cart/item/:id/update' do
        if session[:user_id]
          new_quantity = params[:quantity].to_i
          if new_quantity > 0
            db.execute('UPDATE cart_items SET quantity = ? WHERE id = ?', new_quantity, params[:id])
          else
            db.execute('DELETE FROM cart_items WHERE id = ?', params[:id])
          end
          redirect '/cart'
        else
          redirect '/user/login'
        end
      end

    post '/logout_account' do
        session.destroy
        redirect '/products'
    end 
end
