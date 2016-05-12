#!/usr/bin/python
# pip install flask flask-restful pillow boto3

from flask import Flask, jsonify, abort, make_response, request
from flask.ext.restful import Api, Resource, reqparse, fields, marshal
import uuid
import os
import boto3
if os.name == 'nt':
	from PIL import Image
	
app = Flask(__name__, static_url_path="")
api = Api(app)

S3_ACCESS_KEY = 'YSBDCQOZGH5NUG355HQY'
S3_SECRET_KEY = 'DI/7+RyiQXtGM5yQhEoaouMX+phAZmXktvK6ctuN'
S3_ENDPOINT = 'https://10.65.57.176:8082'
BUCKET = 'camera0'

# Comment out the appropriate one; raspistill is native camera fsweb is usb camera
#COMMAND = 'fswebcam -r 640x480 --jpeg 85 --delay 1 '
COMMAND = 'raspistill -hf -vf -o '

class TakePhotoAPI(Resource):

	def get(self):
		return self.post()

	def post(self):
		# Maybe do something with post variables later...
		try:
			req = request.json		
		except:
			pass

		# Take photo
		filename = str(uuid.uuid4())
		if os.name == 'nt':
			os.system('CommandCam.exe /quiet /filename ' + filename)
			im = Image.open(filename)
			im.save(filename + '.jpg', 'JPEG')
			os.remove(filename)
			filename += '.jpg'
		else:
			filename += '.jpg'
			os.system(COMMAND + filename)

		# Upload to S3
		session = boto3.session.Session(aws_access_key_id=S3_ACCESS_KEY, aws_secret_access_key=S3_SECRET_KEY)
		s3 = session.resource(service_name='s3', endpoint_url=S3_ENDPOINT, verify=False)
		obj = s3.Object(BUCKET, filename)
		obj.upload_file(filename)
		os.remove(filename)
		url = S3_ENDPOINT + "/" + BUCKET + "/" + filename
		
		# Return success
		print ('## Took photo and saved it at: ' + url)
		return make_response(jsonify({'message' : "Took photo with camera", "image_url" : url}), 200)

api.add_resource(TakePhotoAPI, '/take_photo')

if __name__ == '__main__':
	app.run(host='0.0.0.0', debug=True )

