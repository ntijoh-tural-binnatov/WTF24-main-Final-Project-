class App < Sinatra::Base
    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        @title = "MatCheck: Gear Up, Go for Gold!"
        erb :'index'
    end

    get '/categories' do
        @title = "MatCheck: Gear Up, Go for Gold!"
        @categories = db.execute('SELECT * FROM categories')
        erb :'products/index'
    end

    get '/categories/:id' do
        @product = db.execute('SELECT * FROM products WHERE id = ?', params[:id]).first
        @title = @product["name"]
        erb :'products/show'
    end
end
