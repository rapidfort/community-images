from concurrent import futures
import grpc
from grpc_health.v1 import health_pb2_grpc, health_pb2

class HealthServicer(health_pb2_grpc.HealthServicer):
    def Check(self, request, context):
        response = health_pb2.HealthCheckResponse()
        response.status = health_pb2.HealthCheckResponse.SERVING
        return response

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    health_pb2_grpc.add_HealthServicer_to_server(HealthServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Server started at [::]:50051")
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
