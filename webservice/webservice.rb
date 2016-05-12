require 'sinatra'
require 'json'
require 'aws-sdk'
require 'socket'
require 'elasticsearch'
require 'securerandom'
require 'date'

# Modify this section
#$endpoint = 'https://****STORAGEGRID HOSTNAME/IP****:8082'
#$bucket_name = '****YOUR BUCKET NAME****'
#access_key = '****ACCESS KEY****'
#secret_access_key = '****SECRET ACCESS KEY****'

$endpoint = 'https://10.65.57.176:8082'
$bucket_name = 'camera0'
access_key = 'YSBDCQOZGH5NUG355HQY'
secret_access_key = 'DI/7+RyiQXtGM5yQhEoaouMX+phAZmXktvK6ctuN'

es_config = {host: "sdt-linux-infra4.nltestlab.hq.netapp.com:9200"}

$es = Elasticsearch::Client.new(es_config)

cred = Aws::Credentials.new(access_key, secret_access_key)
$client = Aws::S3::Client.new(region: 'us-east-1', endpoint: $endpoint, credentials: cred, force_path_style: true, ssl_verify_peer: false)

get "/" do
  content_type :json
  {:message => "Webservice is running"}.to_json
end

get "/take_photo" do
  content_type :json
  bucket = $bucket_name
  image_url = write_webcam_image_to_s3(bucket)

  #log information into elasticsearch
  ip_address = Socket.ip_address_list[1].ip_address
  ts = DateTime.now.strftime('%Q').to_i
  $es.index index: 'raspberries', type: 'ip_info', body: { ip_address: ip_address, timestamp: ts }

  {:message => "Took photo with camera", :image_url => image_url}.to_json
end

def write_webcam_image_to_s3(bucket)
  # Create random name for image
  image_name = SecureRandom.hex(32) + ".jpg";
  
  # Take picture and store it as image_name
  cli_cmd = "fswebcam -r 640x480 --jpeg 85 --delay 1 " + image_name
  `#{cli_cmd}`

  # Open Image file & upload it to StorageGRID
  image_file = File.open(image_name, "r+")
  $client.put_object(bucket: bucket, key: image_name,
    metadata: { 'foo' => 'bar' },
    body: image_file.read,
    server_side_encryption: 'AES256'
  )
  image_file.close

  # Delete temporary image file from disk
  File.delete(image_file)

  # return full URL of image
  $endpoint + "/" + bucket + "/" + image_name
end
