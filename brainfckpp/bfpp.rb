#! /usr/bin/ruby		
				

#             ===================================================
#	             Brainfuck++ aka bfpp interpreter
#             ====================================================
#     Brainfuck interpreter with the proposed syntax from 

#      www.jitunleashed.com/bf/index.html

#      Copyright (C) 2009 Cyriac Thomas, Narayanan K, Abin Joy, Sandeep George Cherian.

#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    To receive a copy of the GNU General Public License,
#    Write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


require "socket"			#Loading the Socket Library.

module Turing				#Basic Turing machine Data Structure.
	def init_Turing
	@machine=[0]*30000		#Turing Machine Tape.
	@ptr=0				#Pointer
	end
end

module DstructBf
	def init_Dsbf			#Bf loop Data structure
	@save=[]			
        @count=0
	end
end

module DstructBfpp			#Data structures for Bfpp
	def init_Dsbfpp			#such as filename, i/p,socket,port
	@filename=""			#filestream,socketstream
	@ip=""
	@port=""
	@file=0
        @sock=0
	end
end


module Flags
	def flag
	@fileflag=0			#Flags to check the current condition
	@sockflag=0			#of files and socket. 1 if open.
	end
end


class Bf				#Basic Bf data structure
include Turing				#Inheriting Turing using mixin
include DstructBf			#Inheriting Basic Datastructure for Bf

def initialize
init_Turing				#Initializing the Turing
init_Dsbf				#Initializing the Bf Data Structures
end

def a 
	@ptr=@ptr+1				#move the pointer one position to the right		
	@ptr=0 if @ptr==30000			#turn around the tape if the tape is on a right most end of the tape.

end

def b
	@ptr=@ptr-1				#move the pointer one position to the left
	@ptr=29999 if @ptr==-1			#turn around the tape if the tape is on the left most end of the tape.

end

def c
	@machine[@ptr]+=1			#increment the value of the current cell


end

def d
	@machine[@ptr]-=1			#decrement  the value of the current cell

end

def e
	@machine[@ptr]=STDIN.getc		#get a "character" from the input

end

def f
         print @machine[@ptr].chr		#put a "character" to the output

end

def j						#if instruction is [ place the location of 
	if @machine[@ptr]==0 && @count==0
	  until $buff[$i]== 'k'
	      $i+=1
	  end
	else
	if @machine[@ptr]==0 && @count != 0
	  $i=@save[@count]
	@count-=1
	else
	  @count+=1
	  @save[@count]=$i
	end
	end

end

def k
    if(@machine[@ptr])!=0 then			#if instruction is ] and content is non zero
     $i=@save[@count]     			# get the location of the previous [
    else
      @count-=1					#else pop the stack
    end

end 
 
end	#End of BF class




class Bfpp < Bf					#inheriting Bfpp class with default Bf 
include DstructBfpp				#including Bfpp data structures via mixins
include Flags					#including Bfpp Flags via mixins

def initialize
super						#initializing the parent class Bf
init_Dsbfpp					#Initializing Bfpp data structures
flag						#Initializing Bfpp flags
end

def l			   			#Extracting the filename from the turing and opening the file 					
     old=@ptr					#save current pointer
     @ptr+=@machine[@ptr]			#change pointer to the offset
     	while @machine[@ptr] != 0 		#extracting the filename	
           @filename<<@machine[@ptr].chr    	
	   @ptr+=1
           @ptr=0 if @ptr==30000
	end

	@ptr=old
        
         if @fileflag ==  0			#checking if a file is open/close
          if File.exists?(@filename)
	   @file= File.open(@filename,"r+")	#if file exists open in appending mode
	  else
	   @file= File.new(@filename,"w+")	#else open in writing mode
	  end	

	   @fileflag=1				#set fileflag
	  else 
	   @file.close				#if already opened, close it
          end

end

def m						#File Reading: Reading one character at a time into the turing machine for each ":"
   value=@file.getc				#Reading a character from the file and incrementing the filepointer
    if value == NIL 
	@machine[@ptr]=0			#placing 0 to ptr if EOF
    else
	@machine[@ptr]=value			#placing value frm the file.

   end 

end

def n						#File Writing: Writing one character from the turing machine to the opened file for each ";"
	save=@file.tell				#save existing filepointer
	@file.seek(0,IO::SEEK_END)		#move to EOF
	@file.putc(@machine[@ptr].chr)		#put data
	@file.seek(save,IO::SEEK_SET)		#come back to the old location

end

def o						#Open Socket
	if @sockflag == 0			#Checking if socket is open
	  old=@ptr				#extracting i/p and port in the form
	  @ptr+=@machine[@ptr]			#addr=ip:port
	  addr=""
		  while @machine[@ptr] != 0
		    addr<<@machine[@ptr].chr
		    @ptr+=1
		  end
		  @ip, @port= addr.split(":") 	#spliting ip and port
	  @ptr=old
	  @sock = TCPSocket.new(@ip,@port)	#opening socket
	  @sockflag=1				#setting socket flag

	else
	  @sock.close				#if already open close it.
	  @ip=""				#clear the ip
	  @port=""
	end

end

def p						#Read frm Socket 
	x=@sock.getc				#Read a character from socket
	if @sock.getc == 4			#place 0 to ptr if EOT
	@machine[@ptr]=0
	else
	@machine[@ptr]=x			#else place the character
	end


end

def q
	x=@machine[@ptr].chr			#Write to socket
	@sock.putc(x)
end


def r

  extra_key_junk=STDIN.gets.chomp		#required without exception as it needs to catch the old character from bf output. 
						#But later on it pauses.
  puts "Current pointer: " + @ptr.to_s		#print the current pointer location.
  ti=$i+1
  siz=$buff.size - $i
  if siz > 5
  siz = $i+6
  end
  print "Next 5 instructions: "			#print next five instructions or the next instructions which ever is smaller.
  while ti < siz
    print $buff[ti].chr.tr('abcdefjklmnopqrs','><+\-,.[]#:;%^!D=')
    ti+=1
  end
  puts ""
  print "Enter range: "				#accept the range of the tape to be displayed.
	range=STDIN.gets.chomp
	x,y=range.split("-")			#split it with the hyphen


	x=x.to_i
	r=x
	y=y.to_i+1
	
	until x == y do				#display the range of values
	print @machine[x]
	print " | "
	x+=1
	end
	puts "\n"
	print "EDIT(y/n)?"			#ask user for edit?
	ans=STDIN.gets.chomp
	x=r
	if ans == 'y'				#if yes accept the new values to machine[x] to machine[y]
	print "Enter the data in ascii:"
	  until x == y
	    @machine[x]=STDIN.gets.chomp.to_i
	    x+=1
	  end
	  x=r
	  x=x.to_i
	  until x == y				#display the new values.
	    print @machine[x]
	    print " | "
	    x+=1
	  end
	
	end
 end		#End of Debug

end		#End Of Bfpp Class
	
=begin
	MAIN
=end

obj = Bfpp.new			#Bfpp object aka Turing machine
$i=0
if ARGV[0] == "-d"		#chekcing if the user has requested debug mode
	ARGV.shift		#if debug mode use the D instruction. and then shift the Cmd arguments one position left to get filename in ARGV[0]
	$buff=$<.readlines.join.tr('^><+\-,.[]#:;%^!D=','').tr('><+\-,.[]#:;%^!D=','abcdefjklmnopqrs')  #tr finally translates symbols into alphabets and stores in x 
else
	$buff=$<.readlines.join.tr('^><+\-,.[]#:;%^!=','').tr('><+\-,.[]#:;%^!=','abcdefjklmnopqs')  #tr finally translates symbols into alphabets and stores in x 
end  
while $i<$buff.size		#Traversing through the buffer sequentially
if $buff[$i].chr=='s'		#if comment
$i+=1	
    while $buff[$i].chr!='s'	#seeking till next = aka comment close
	$i+=1
    end
$i+=1				#incrementing the buffer index
else
obj.send($buff[$i].chr)	                     # sends message (characters) to class
$i+=1				#incrementing the buffer index
end
end	#end of while $i<x.size


#Copyright (C) 2009 Cyriac Thomas, Narayanan K, Abin Joy, Sandeep George Cherian. Cochin,Kerala,India.


