from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
from pprint import pprint

load_dotenv()

app = Flask(__name__)

# In-memory data store (a list to hold items)
items = []

# POST /items - Create a new item
@app.route('/items', methods=['POST'])
def create_item():
    data = request.json
    if not data or not 'name' in data:
        return jsonify({'error': 'Item name is required'}), 400

    item = {
        'id': len(items) + 1,  # Auto-increment ID
        'name': data['name']
    }
    items.append(item)
    return jsonify(item), 201

# GET /items - List all items
@app.route('/items', methods=['GET'])
def list_items():
    return jsonify(items), 200


if __name__ == '__main__':
    pprint(app.config)
    app.run(debug=app.config['DEBUG'])