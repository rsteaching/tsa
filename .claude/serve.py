import http.server, socketserver, functools, os

PORT = 8911
DIRECTORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

Handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=DIRECTORY)

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
