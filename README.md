# hackathon-zrh

Sample project for the Amsterdam Hackathon.

The project consistes of two services:

* webservice: Webservice based on Sinatra with Ruby. Runs on Rapsberry Pi. Will trigger the attached camera to a picture, then upload it to an S3 target. 
* webclient: Containerized website, running on Sinatra with Ruby. Will connect to the webservice and then display the last 10 pictures taken.

Note: IP addresses and credentials are hardcoded and need to be changed before build/run.

## Usage

### webservice

* `docker build .` builds the container
* `docker run --rm -p 8080:8080 <image_id>` runs the container
* `docker ps` lists all running containers
* `docker stop <id>` stops an running container

Once the container runs, you can access it via `http://localhost:8080`

You can also run the webservice manually:
* `shotgun --host 0.0.0.0 --port 8080 webservice.rb`

However, you will need to have the following gems installed:
* `gem install shotgun`
* `gem install sinatra`
* `gem install aws-sdk`

### webclient

* `docker build .` builds the container
* `docker run --rm -p 8081:8081 <image_id>` runs the container
* `docker ps` lists all running containers
* `docker stop <id>` stops an running container

Once the container runs, you can access it via `http://localhost:8081`

You can also run the webservice manually:
* `shotgun --host 0.0.0.0 --port 8081 webclient.rb`

However, you will need to have the following gems installed:
* `gem install shotgun`
* `gem install sinatra`
* `gem install unirest`
* `gem install haml`

### S3 Bucket Policy

* The bucket policy can easy be set under Windows with s3 browser
* On MacOSX, the easiest way is to use s3cmd: `s3cmd setpolicy bucket_policy.json s3://bucketname`
