class App < Sinatra::Base

	enable:sessions

	get '/' do
		db = SQLite3::Database::new("./JTS_series.db")
		pic = db.execute("SELECT pic FROM Series WHERE name IS ?", "Game of Thrones")[0][0]
	
		if session[:user_id]
			current_id = session[:user_id]
			db = SQLite3::Database::new("./jts.db")
			name = db.execute("SELECT name FROM users WHERE id IS ?", [current_id])
			erb(:main, locals:{name: name, pic: pic})
		else
			erb(:main, locals:{pic: pic})
		end
	end

	get '/login' do
		erb(:login)
	end

	get '/new_user' do
		erb(:new_user)
	end

	post '/login' do
		name = params[:name]
		password = params[:password]
		db = SQLite3::Database::new("./jts.db")
		real_password = db.execute("SELECT password FROM users WHERE name=?", [name])
		if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
			session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", [name])[0][0]
			redirect('/')
		else
			erb(:login, locals:{failure: "Wrong password or username. Please try again."})
		end
	end

	post '/new_user' do
		new_name = params[:name]
		new_password = params[:password]
		confirmed_password = params[:confirmed_password]
		if new_password == confirmed_password
			db = SQLite3::Database::new("./jts.db")
			taken_name = db.execute("SELECT * FROM users WHERE name IS ?", [new_name])
			if taken_name == []
				hashed_password = BCrypt::Password.create(new_password)
				db.execute("INSERT INTO users (name, password) VALUES (?,?)", [new_name, hashed_password])
				redirect('/')
			else
				erb(:new_user, locals:{failure: "Username is already taken."})
			end
		else
			erb(:new_user, locals:{failure: "Passwords didn't match. Please try again."})
		end
	end  

	get '/serie/:name' do
		serie = params[:name]
		erb(:serie, locals: {serie:serie})
	end
	
	get '/profile' do
		if session[:user_id]
			current_id = session[:user_id]
			db = SQLite3::Database::new("./jts.db")
			name = db.execute("SELECT name FROM users WHERE id IS ?", [current_id])
			erb(:profile, locals:{name: name})
		else
		erb(:profile)
	end
end
end