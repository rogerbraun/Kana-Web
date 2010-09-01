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
  url "http://kanaweb.heroku.com/"
  callback "http://kanaweb.heroku.com/"
end

get "/" do
  haml :index
end

get "/facebook" do
  fb.require_login!
  "Hi <fb:name uid=#{fb[:user]} useyou=false />!"
end

