require 'sinatra'
require 'aws-sdk'
require 'unirest'

# Modify this section
raspberry_ip = '****IP OF RASPBERRY****'

Unirest.timeout(20)

get "/" do
  haml :index
end

get "/take_photo" do
  response = Unirest.get "http://#{raspberry_ip}:8080/take_photo"
  @image_url = response.body['image_url'].to_s
  haml :show_photo
end
