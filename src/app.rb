class App < Sinatra::Base

    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/user/login' do
        erb :'user/login_account'
    end

    get '/user/register' do
        erb :'user/register_account'
    end

    post '/user/register' do
        username = params["username"]
        password = params["password"]
        db.execute('INSERT INTO users_account (username, password) VALUES (?,?)', username, password)
        redirect '/'

    end

    post '/user/login' do
        user = db.execute('SELECT * FROM users_account WHERE username = ?', params[:username]).first
        if user['password'] == params[:password]
            redirect '/products/1'
        else
            redirect '/products/404'
        end
    end

    get '/' do
        redirect '/products'
    end

    get '/products' do 
        @products = db.execute('SELECT * FROM products')
        @tags = db.execute('SELECT * FROM tags')
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id')
        erb :'products/index'
    end

    get '/products/new' do
        erb :'products/new'
    end 
    
    get '/products/product/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        @reviews = db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id WHERE products.id = ?', id)
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON products.id = product_tags.product_id WHERE products.id = ?', id)
        sum_ratings = 0
        värde = 0.0
        @reviews.each do |review|
            sum_ratings += review['rating'].to_i
            värde += 1
        end
        if (värde == 0)
            @rating = "Review this product!"
        else
            @rating = "#{(sum_ratings/värde).round(2)}/5" 
        end
        erb :'products/show'
    end

    get '/products/:id' do |id|
        @products = []
        # Hämtar taggens ID från databasen med det givna taggnamnet
        tag = db.execute('SELECT * FROM tags WHERE tag_name = ?', id).first
        if tag
            tag_id = tag['id']
            # Hämtar alla produkt-tag-förhållanden för den valda taggen
            product_tags = db.execute('SELECT * FROM product_tags WHERE tag_id = ?', tag_id)
            # Loopa igenom produkt-tag-förhållandena och hämta motsvarande produkter
            product_tags.each do |product_tag|
                product_id = product_tag['product_id']
                product = db.execute('SELECT * FROM products WHERE id = ?', product_id).first
                @products << product if product
            end
        else
            # Om taggen inte hittas, skapa ett felmeddelande eller hantera situationen på annat sätt
            @error_message = "Tag not found: #{id}"
        end
        # Hämta alla taggar och produkt-tag-förhållanden för visning i vyn
        @tags = db.execute('SELECT * FROM tags')
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id')
        erb :'products/index'
    end
    
    post '/products/tags' do
        tag = params["tag"]
        redirect "/products/#{tag}"
    end
    

    post '/products/tags' do
        tag = params["tag"]
        redirect "/products/#{tag}"
    end

    post '/products/create' do
        file = params[:file][:tempfile]
        file_name = SecureRandom.alphanumeric(16)
        file_path = "img/product/#{file_name}.jpg"

        File.open("public/#{file_path}", 'wb') do |f|
            f.write(file.read)
        end

        result = db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?) RETURNING *', params[:name], params[:description], params[:price], file_path).first
        redirect "/products/#{result["id"]}"
    end
    
    get '/products/:id/delete' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        erb :'products/delete'
    end

    post '/products/review/:id' do |id|
        result = db.execute('INSERT INTO reviews (rating, review) VALUES (?, ?) RETURNING *', params[:rating], params[:review]).first
        db.execute('INSERT INTO product_reviews (product_id, review_id) VALUES (?, ?)', id, result['id'])
        redirect "/products/#{id}"
    end

    post '/products/:id/delete' do |id|
        product = db.execute('SELECT FROM products WHERE id = ?', id)
        File.delete(product['image_path'])
        db.execute('DELETE FROM products WHERE id = ?', id)
        redirect "/products"
    end

    get '/reviews/:id/delete' do |id|
        @review = db.execute('SELECT * FROM reviews WHERE id = ?', id).first
        erb :'reviews/delete'
    end

    post '/reviews/:id/delete' do |id|
        product_id = db.execute('SELECT * FROM product_reviews WHERE review_id = ?', id).first['product_id']
        db.execute('DELETE FROM product_reviews WHERE review_id = ?', id)
        db.execute('DELETE FROM reviews WHERE id  = ?', id)
        redirect "/products/index"
    end
end 