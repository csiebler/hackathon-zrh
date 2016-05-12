require 'sinatra'
require 'json'
require 'aws-sdk'
require 'securerandom'

# Modify this section
$endpoint = 'https://****STORAGEGRID HOSTNAME/IP****:8082'
$bucket_name = '****YOUR BUCKET NAME****'
access_key = '****ACCESS KEY****'
secret_access_key = '****SECRET ACCESS KEY****'

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
