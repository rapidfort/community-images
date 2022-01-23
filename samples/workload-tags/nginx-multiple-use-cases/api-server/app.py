import os
import time
import tornado.ioloop
import tornado.web

class HealthCheckHandler(tornado.web.RequestHandler):
    def get(self):
        self.set_status(200)

class DateHandler(tornado.web.RequestHandler):
    def get(self):
        output = os.getenv("SERVER_ID","") + ": " + time.ctime()
        self.write({"output": output})

def make_app():
    return tornado.web.Application([
        (r"/", HealthCheckHandler),
        (r"/api/date", DateHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(80)
    tornado.ioloop.IOLoop.current().start()

