import os
import redis
import sys

host = os.getenv('REDIS_HOST', 'localhost')
port = int(os.getenv('REDIS_PORT', 6379))

try:
    r = redis.Redis(host=host, port=port, socket_connect_timeout=5)
    if r.ping():
        print("✅ Redis is reachable")
    else:
        print("❌ Redis ping failed")
        sys.exit(1)
except Exception as e:
    print("❌ Redis connection error:", e)
    sys.exit(1)