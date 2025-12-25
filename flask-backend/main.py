import os
from flask import Flask
from flask_cors import CORS
from routes.similarity import similarity_bp
from routes.cluster import cluster_bp
import matplotlib

# Headless server fix
matplotlib.use("Agg")


def create_app():
    app = Flask(__name__)
    CORS(app)

    app.register_blueprint(similarity_bp)
    app.register_blueprint(cluster_bp)

    return app


if __name__ == "__main__":
    app = create_app()

    host = os.environ.get("HOST", "127.0.0.1")
    port = 3011

    app.run(
        host=host,
        port=port,
        debug=False
    )
