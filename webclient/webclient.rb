require 'sinatra'
require 'unirest'
require 'elasticsearch'
require 'date'

es_config = {host: "sdt-linux-infra4.nltestlab.hq.netapp.com:9200"}

es = Elasticsearch::Client.new(es_config)
Unirest.timeout(20)

get "/" do

  response = es.search index: 'raspberries', q: '*'
  @ips = []
  response['hits']['hits'].each do |r|
    @ips << r['_id']
  end

  haml :index
end

get "/take_photo/:ip" do
  raspberry_ip = params[:ip]

  response = Unirest.get "http://#{raspberry_ip}:8080/take_photo"
  @image_url = response.body['image_url'].to_s
  
  haml :show_photo
end
