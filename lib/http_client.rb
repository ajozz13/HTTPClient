=begin
     This program is a simple client to do POST, PUT, DELETE and GET
=end

require "net/http"
require "net/https"
require "uri"
require 'json'
require 'ostruct'


class HTTPClient
#variables
     attr_accessor :debug, :url, :headers, :proxy_address
     attr_reader :response_code, :response_message, :response_headers

     def initialize url=nil, debug=false
          @url = url unless url.nil?
          @debug = debug
     end

#inner_classes
     class HTTPException < StandardError
          attr_accessor :code, :msg, :exit_code, :body

          def initialize msg, code, exit_code
               @msg = msg
               @code = code
               @exit_code = exit_code  # between 1 and 255
          end

          def to_s
               "#{ @code } - #{ @msg }\nBody: #{ @body }"
          end
     end

#functions
     def send_request method, request_body=nil, query_array=nil

          raise HTTPException.new( "URL not defined", 500, 1 ) if @url.nil?

          unless @proxy_address.nil? 
               ENV[ 'http_proxy' ] = @proxy_address 
               @use_proxy = true
          end
          proxy_uri = URI.parse( ENV[ 'http_proxy' ] ) if @use_proxy

          uri = URI.parse @url

          uri.query = URI.encode_www_form( query_array ) unless query_array.nil?
         
          if @debug   
               puts "Host: #{ uri.host } Port: #{ uri.port } Path: #{ uri.path }"       
               puts "URI: #{ uri.request_uri }"
               puts "Path: #{ uri.path }"
               puts "Proxy: #{ proxy_uri.host } #{ proxy_uri.port }" if @use_proxy
               puts "-----------------------------"
          end
          print "Set up Connection....." if @debug

          http = Net::HTTP.new( uri.host, uri.port )
          http.use_ssl = uri.scheme.eql? "https"
          puts "Use SSL? #{ http.use_ssl? }" if @debug

          hdrs = @headers.nil? ? Hash.new : @headers
          request = case method.upcase
               when "POST"
                    print "POST Method...." if @debug
                    Net::HTTP::Post.new( uri.request_uri, hdrs )
               when "PUT"
                    print "PUT Method...." if @debug
                    Net::HTTP::Put.new( uri.request_uri, hdrs )
               when "DELETE"
                    print "DELETE Method...." if @debug
                    Net::HTTP::Delete.new( uri.request_uri, hdrs )
               when "GET"
                    print "GET Method...." if @debug
                    Net::HTTP::Get.new( uri.request_uri, hdrs )
               when "HEAD"
				puts "HEAD Method" if @debug
				Net::HTTP::Head.new( uri.request_uri, hdrs )
          end

          request.body = request_body unless request_body.nil?

          print "Done.\nConnecting....."  if @debug

          response = http.request( request )
          puts "Response: ( #{ response.code } - #{ response.message } )" if @debug 
          @response_code = response.code.to_i
          @response_message = response.message  
          @response_headers = response.to_hash
          if @debug
               
               puts "-----------------------------"
               puts "Headers Received:"
               #puts "#{ response.to_hash.inspect }"
               response.each_header do |key, value|
                    puts "#{ key }: #{ value }"
               end
               puts "-----------------------------"
               puts "CL: #{ response[ "content-length" ] }" 
               puts "----BODY----"
               puts response.body
               puts "-----------------------------"
          end
          response.body
     end

     def to_json json_string
          JSON.parse( json_string, object_class: OpenStruct )
     end

end



#main  TEST CASE
=begin
begin
     $debug = ARGV.include? "-d"
     use_http_proxy = ARGV.include? "-p"

     client = HTTPClient.new "https://api.pactrak.com/v1/res/dispositioncodes", $debug
     rep = client.send_request "GET"
     js = client.to_json rep
     puts "#{ client.response_code } - #{ client.response_message }"
     puts "#{ js.message }"
     

rescue HTTPClient::HTTPException => x
     STDERR.write "#{ x }"
     puts "Backtrace:"
     puts x.backtrace
     exit x.exit_code
rescue Exception => e
     STDERR.write "#{ e }"
     puts "Backtrace:"
     puts e.backtrace
     exit 1
end
exit 0
=end

