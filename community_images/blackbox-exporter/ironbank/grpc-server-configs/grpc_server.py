"""
A basic gRPC server that serves health checks to test gRPC probing in blackbox exporter.
"""
# pylint: disable=import-error, invalid-name, unused-argument

from concurrent import futures
import grpc
from grpc_health.v1 import health_pb2_grpc, health_pb2

class HealthServicer(health_pb2_grpc.HealthServicer):
    """
    Implements the gRPC HealthServicer for health checking.
    """

    def Check(self, request, context):
        """
        Checks the health status of the server.

        Args:
            request: The health check request.
            context: The gRPC context.

        Returns:
            The health check response with the status set to SERVING.
        """
        response = health_pb2.HealthCheckResponse()
        response.status = health_pb2.HealthCheckResponse.SERVING
        return response


def serve():
    """
    Starts the gRPC server and serves health checks.

    This function creates a gRPC server, adds the HealthServicer to it, and starts the server on port 50051.
    It then waits for the server to terminate.
    """
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    health_pb2_grpc.add_HealthServicer_to_server(HealthServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Server started at [::]:50051")
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
