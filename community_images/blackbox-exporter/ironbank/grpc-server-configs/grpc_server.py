from concurrent import futures
import grpc
import example_pb2
import example_pb2_grpc

class ExampleService(example_pb2_grpc.ExampleServiceServicer):
    def SayHello(self, request, context):
        response = example_pb2.HelloResponse()
        response.message = 'Hello, {}'.format(request.name)
        return response

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    example_pb2_grpc.add_ExampleServiceServicer_to_server(ExampleService(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("gRPC server running on port 50051")
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
