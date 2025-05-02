from flask import Flask
from flask_cors import CORS
from routes.similarity import similarity_bp
from routes.cluster import cluster_bp

def create_app():
    app = Flask(__name__)
    CORS(app)
    app.register_blueprint(similarity_bp)
    app.register_blueprint(cluster_bp)
    return app

if __name__ == '__main__':
    import matplotlib
    matplotlib.use('Agg')  # For headless server environments

    app = create_app()
    app.run(debug=True)
