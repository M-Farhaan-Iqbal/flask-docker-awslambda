import awsgi
from flask import Flask, jsonify, request

import sys

app = Flask(__name__)
#todo
@app.route('/')
def hello():
    return jsonify(message='Hello from AWS Lambda using Python Flask in Docker!')

@app.route('/health')
def hello():
    return jsonify(message='health okay')

@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    return jsonify(data)

if __name__ == '__main__':
    app.run()

def lambda_handler(event, context):
    return awsgi.response(app, event, context)

