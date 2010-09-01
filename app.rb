require "rubygems"
require "sinbook"
require "sinatra"
require "haml"
require "datamapper"

require "models/Kana.rb"


DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite:db/dev.db")

DataMapper.auto_upgrade!

facebook do
  api_key "095013a6174927028e52bc5c6652be1e"
  secret "6c06a0379eb2af215a66e76d95a75c4e"
  app_id "115027275218758"
  url "http://kanaweb.heroku.com"
  callback "http://kanaweb.heroku.com"
end

helpers do

  def logged_in?
    if session[:uid] then true end
    
    if fb[:user] then
      session[:uid] = User.get_by_fb.id
      return true
    end
  end

  def current_user
    User.get(session[:uid])
  end
 
end

get "/" do

  if logged_in?
    haml :index
  else
    haml :facebook
  end

end


get '/receiver' do
  %[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" >
  <body>
      <script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/XdCommReceiver.js" type="text/javascript"></script>
  </body>
  </html>]
end

