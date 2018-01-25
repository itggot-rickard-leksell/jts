
class App < Sinatra::Base

	get '/' do
		erb(:main)
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
		db = SQLite3::Database::new("./database/user_notes.sqlite")
		real_password = db.execute("SELECT password FROM users WHERE name=?", [name])
		if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
			session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", [name])[0][0]
			redirect('/login')
		else
			redirect('/')
		end
	end

	post '/new_user' do
		new_name = params[:name]
		new_password = params[:password]
		confirmed_password = params[:confirmed_password]
		if new_password == confirmed_password
			db = SQLite3::Database::new("./database/user_notes.sqlite")
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
end     
