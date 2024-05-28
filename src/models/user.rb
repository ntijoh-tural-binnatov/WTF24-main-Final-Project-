module User
    def self.all(db)
      db.execute('SELECT * FROM users_account')
    end
  
    def self.find_username(db, username)
      db.execute('SELECT * FROM users_account WHERE username = ?', username)
    end
  
    def self.create_account(db, username, password, mail, role)
      hashed_password = BCrypt::Password.create(password)
      db.execute('INSERT INTO users_account (username, password, mail, role) VALUES (?,?,?,?)', username, hashed_password, mail, role)
    end

    def self.username_users_account(user_id)
      db.execute('SELECT username FROM users_account WHERE id = ?', user_id).first
    end
end
  