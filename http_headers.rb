#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'uri'

class HttpHeaders < EventMachine::Connection
  attr_accessor :host, :port, :path 
  
  def initialize(*args)
    super
  end
  
  def post_init
    @data = ""
  end
  
  def receive_data(data)
    @data << data
    
    if data =~ /[\r][\n][\r][\n]/
      close_connection
    end
  end
  
  def unbind
    @data.each_line do |line|
      break if line.strip.length == 0 
      puts line
    end
    
    EventMachine::stop_event_loop
  end
end

urls = URI::extract(ARGV.join(' '))
urls.each do |url|
  uri = URI::parse(url)
  puts "======"
  puts "Process url: host = #{uri.host} port = #{uri.port} path = #{uri.path}"
  puts "======"
  EventMachine::run do
    EventMachine::connect uri.host, uri.port, HttpHeaders do |conn|
      path = '/'
      path = uri.path if uri.path.length > 0
      conn.send_data "HEAD #{path} HTTP/1.1\r\nHost: #{uri.host}\r\n\r\n"
    end
  end
end