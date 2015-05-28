#! /usr/bin/ruby
require 'socket'               # Get sockets from stdlib

server = TCPServer.open(1221)  # Socket to listen on port 2000
client = server.accept       # Wait for a client to connect     
#  x=client.gets
# client.puts(Time.now.ctime)  # Send the time to the client
# client.puts "Closing the connection. Bye!"
#  puts x.to_s
x=client.getc
#puts "got"
puts x.to_s
client.close                 # Disconnect from the client


