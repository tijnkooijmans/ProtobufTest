#!/usr/bin/python

import SocketServer
import time
import binascii
import machine_pb2

class MyTCPHandler(SocketServer.BaseRequestHandler):
    """
    The RequestHandler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """

    def handle(self):
        print "Client connected"
        while (1):
            data = self.request.recv(1024)
            time.sleep(0.01)

            if (data):
                print "received data: %s" % binascii.hexlify(data)

                currentStatus = machine_pb2.MachineStatus()
                currentStatus.ParseFromString(data)
                print currentStatus

                currentStatus.temps[0] = currentStatus.temps[0] / 2
                currentStatus.fanSpeeds[0] = currentStatus.fanSpeeds[0] / 2
                self.request.send(currentStatus.SerializeToString())
            

			

if __name__ == "__main__":
    HOST, PORT = "127.0.0.1", 10013

    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
	
    print "Waiting for client to connect"

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
	
