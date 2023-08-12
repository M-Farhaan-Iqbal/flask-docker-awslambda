import awsgi
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

app = Flask(__name__)

# Load environment variables
db_config = {
    'user': os.environ.get('PGUSER'),
    'password': os.environ.get('PGPASSWORD'),
    'host': os.environ.get('PGHOST'),
    'port': os.environ.get('PGPORT'),
    'database': os.environ.get('PGDATABASE'),
}

db_url = "postgresql://{user}:{password}@{host}:{port}/{database}".format(**db_config)
app.config['SQLALCHEMY_DATABASE_URI'] = db_url
db = SQLAlchemy(app)

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(80), unique=True, nullable=False)
    content = db.Column(db.String(120), unique=True, nullable=False)

    def __init__(self, title, content):
        self.title = title
        self.content = content

db.create_all()

# Helper function to convert Item object to JSON dict
def item_to_dict(item):
    return {
        'id': item.id,
        'title': item.title,
        'content': item.content,
    }

# CRUD Endpoints
@app.route('/items/<int:id>', methods=['GET'])
def get_item(id):
    try:
        item = Item.query.get(id)
        if item is None:
            return jsonify(message='Item not found'), 404
        return jsonify(item_to_dict(item))
    except Exception as e:
        return jsonify(error=str(e)), 500

@app.route('/items', methods=['GET'])
def get_items():
    items = [item_to_dict(item) for item in Item.query.all()]
    return jsonify(items)

@app.route('/items', methods=['POST'])
def create_item():
    data = request.get_json()
    new_item = Item(data['title'], data['content'])
    db.session.add(new_item)
    db.session.commit()
    return jsonify(message='Item created')

@app.route('/items/<int:id>', methods=['PUT'])
def update_item(id):
    item = Item.query.get(id)
    if item is None:
        return jsonify(message='Item not found'), 404
    
    data = request.get_json()
    item.title = data['title']
    item.content = data['content']
    db.session.commit()
    return jsonify(message='Item updated')

@app.route('/items/<int:id>', methods=['DELETE'])
def delete_item(id):
    item = Item.query.get(id)
    if item is None:
        return jsonify(message='Item not found'), 404
    db.session.delete(item)
    db.session.commit()
    return jsonify(message='Item deleted')

# Additional Endpoints
@app.route('/')
def helloroot():
    return jsonify(message='Hello from AWS Lambda using Python Flask in Docker!')

@app.route('/health')
def health():
    logger.info('## API health check initiated')
    return jsonify(message='Health okay')

@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    logger.info('## Echo data: %s', data)
    return jsonify(data)

# Lambda Handler
def lambda_handler(event, context):
    logger.info('## API event: %s', event)
    response = awsgi.response(app, event, context)
    logger.info('## API response: %s', response)
    return response
