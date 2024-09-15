from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
from pprint import pprint
import redis
import json
from redis.exceptions import ConnectionError

load_dotenv()

app = Flask(__name__)

app.config['REDIS_HOST'] = os.getenv('REDIS_HOST', 'localhost')
app.config['REDIS_PORT'] = int(os.getenv('REDIS_PORT', '6379'))
app.config['REDIS_DB'] = int(os.getenv('REDIS_DB', '0'))

# Initialize Redis client
redis_client = redis.Redis(
    host=app.config['REDIS_HOST'],
    port=app.config['REDIS_PORT'],
    db=app.config['REDIS_DB']
)

# In-memory data store (a list to hold items)
items = []

# POST /items - Create a new item
@app.route('/items', methods=['POST'])
def create_item():
    data = request.json
    if not data or 'name' not in data:
        return jsonify({'error': 'Item name is required'}), 400

    # Generate a new ID
    item_id = redis_client.incr('item_id')

    item = {
        'id': item_id,
        'name': data['name']
    }
    # Store the item in Redis
    redis_client.hset('items', item_id, json.dumps(item))
    return jsonify(item), 201

# GET /items - List all items
@app.route('/items', methods=['GET'])
def list_items():
    items = []
    for key in redis_client.hkeys('items'):
        item_data = redis_client.hget('items', key)
        item = json.loads(item_data)
        items.append(item)
    return jsonify(items), 200

# GET /health - Check if Redis is available
@app.route('/health', methods=['GET'])
def health_check():
    try:
        # Check Redis connection
        redis_client.ping()
        return jsonify({'status': 'healthy'}), 200
    except ConnectionError:
        return jsonify({'status': 'unhealthy'}), 500

if __name__ == '__main__':
    pprint(app.config)
