import os
import time
import tornado.ioloop
import tornado.web

os.environ['TZ'] = 'US/Pacific'
time.tzset()

_SERVER = os.getenv("SERVER_ID","")

class HealthCheckHandler(tornado.web.RequestHandler):
    def get(self):
        self.set_status(200)


class DateHandler(tornado.web.RequestHandler):
    def get(self):
        self.write({"server": _SERVER, "date": time.ctime()})

def make_app():
    return tornado.web.Application([
        (r"/", HealthCheckHandler),
        (r"/api/date", DateHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(80)
    tornado.ioloop.IOLoop.current().start()

