import awsgi
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)

import sys

app = Flask(__name__)

# sample of db connection
# DATABASE_URL=postgresql://postgres:postgres@db:5432/postgres

# rebuilding from environment variables
dburl = "postgresql://"+ os.environ.get('PGUSER') + ":" + os.environ.get('PGPASSWORD') + "@" + os.environ.get('PGHOST') +  ":" + os.environ.get('PGPORT') + "/" +  os.environ.get('PGDATABASE')

logger.info('## Connection to db ')

app.config['SQLALCHEMY_DATABASE_URI'] = dburl
db = SQLAlchemy(app)

class Item(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  title = db.Column(db.String(80), unique=True, nullable=False)
  content = db.Column(db.String(120), unique=True, nullable=False)

  def __init__(self, title, content):
    self.title = title
    self.content = content

with app.app_context():
    db.create_all()

@app.route('/items/<id>', methods=['GET'])
def get_item(id):
    item = Item.query.get(id)
    if item is None:
        return jsonify(message='Item not found'), 404
    
    del item.__dict__['_sa_instance_state']
    return jsonify(item.__dict__)

@app.route('/items', methods=['GET'])
def get_items():
  items = []
  for item in db.session.query(Item).all():
    del item.__dict__['_sa_instance_state']
    items.append(item.__dict__)
  return jsonify(items)

@app.route('/items', methods=['POST'])
def create_item():
  body = request.get_json()
  db.session.add(Item(body['title'], body['content']))
  db.session.commit()
  return "item created"

@app.route('/items/<id>', methods=['PUT'])
def update_item(id):
  body = request.get_json()
  db.session.query(Item).filter_by(id=id).update(
    dict(title=body['title'], content=body['content']))
  db.session.commit()
  return "item updated"

@app.route('/items/<id>', methods=['DELETE'])
def delete_item(id):
  db.session.query(Item).filter_by(id=id).delete()
  db.session.commit()
  return "item deleted"

@app.route('/')
def helloroot():
    return jsonify(message='Hello from AWS Lambda using Python Flask in Docker!')

@app.route('/health')
def hello():
    logger.info('## API for health check initiated ')
    return jsonify(message='health okay')

@app.route('/echo', methods=['POST'])
def echo():
    
    data = request.get_json()
    logger.info('## echo in logs also %s ',data )
    return jsonify(data)


def lambda_handler(event, context):
    logger.info('## API event : %s', event)
    responseApi = awsgi.response(app, event, context)
    logger.info('## API response : %s', responseApi)
    return responseApi
