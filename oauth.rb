require 'rubygems'
require 'sinatra'
require 'oauth'
require 'json'

def client
  OAuth::Consumer.new( 'PUT_YOUR_API_KEY_HERE', 'PUT_YOUR_API_SECRET_HERE', :site => 'https://api.twitter.com' )
end

use Rack::Session::Pool, :expire_after => 2592000

get '/auth/twitter' do
  puts "Redirect URL: #{redirect_uri}"
  request_token = client.get_request_token(:oauth_callback => redirect_uri)
  session[:request_token] = request_token
  redirect request_token.authorize_url(:oauth_callback => redirect_uri)
end

get '/auth/twitter/callback' do
  access_token = session[:request_token].get_access_token
  screen_name = access_token.params[:screen_name]
  oauth_token = access_token.params[:oauth_token]
  oauth_token_secret = access_token.params[:oauth_token_secret]
  "Screen Name: #{screen_name} <br/> Access Token: #{oauth_token} <br/> Access Token Secret: #{oauth_token_secret}"
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/twitter/callback'
  uri.query = nil
  uri.to_s
end
