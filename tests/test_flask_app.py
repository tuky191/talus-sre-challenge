import unittest
from testcontainers.redis import RedisContainer
from app import app
import redis
import json

class TestFlaskApp(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Start the Redis container
        cls.redis_container = RedisContainer("redis:latest")
        cls.redis_container.start()

        # Set up the Redis client for this container
        cls.redis_client = redis.Redis(
            host=cls.redis_container.get_container_host_ip(),
            port=cls.redis_container.get_exposed_port(6379),
            decode_responses=True
        )

        # Update app config to point to this Redis container
        app.config['REDIS_HOST'] = cls.redis_container.get_container_host_ip()
        app.config['REDIS_PORT'] = cls.redis_container.get_exposed_port(6379)

        # Create a test client for the Flask app
        cls.client = app.test_client()

    @classmethod
    def tearDownClass(cls):
        # Stop the Redis container after all tests in the class
        cls.redis_container.stop()

    def setUp(self):
        # Flush Redis to ensure each test starts with a clean state
        self.redis_client.flushdb()

    def test_create_item(self):
        # Make a POST request to create a new item
        response = self.client.post('/items', json={'name': 'Test Item'})
        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertIn('id', data)
        self.assertEqual(data['name'], 'Test Item')

        # Verify the item exists in Redis
        item_id = data['id']
        stored_item = self.redis_client.hget('items', item_id)
        self.assertIsNotNone(stored_item)
        self.assertEqual(json.loads(stored_item)['name'], 'Test Item')

    def test_list_items(self):
        # Insert a couple of items directly into Redis
        self.redis_client.hset('items', 1, json.dumps({'id': 1, 'name': 'Item 1'}))
        self.redis_client.hset('items', 2, json.dumps({'id': 2, 'name': 'Item 2'}))

        # Make a GET request to list all items
        response = self.client.get('/items')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(len(data), 2)
        self.assertEqual(data[0]['name'], 'Item 1')
        self.assertEqual(data[1]['name'], 'Item 2')

    def test_health_check(self):
        # Make a GET request to the /health endpoint
        response = self.client.get('/health')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {'status': 'healthy'})
