#! /usr/bin/ruby
require 'socket'               

server = TCPServer.open(1221) 
client = server.accept 
x="1"
until x == 0             
x=client.getc
print x.chr.to_s
x=x.to_i
end
client.close                 


