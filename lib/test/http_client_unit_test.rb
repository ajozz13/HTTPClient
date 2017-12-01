require_relative "../http_client"
require "minitest/autorun"
require "minitest/pride"

class TestHTTPClient < Minitest::Test

=begin
     HTTPClient is a simple class that can perform HTTP HTTPS requests and can retrieve JSON
     and return HTTP headers from the request
=end
     #setup the client send a simple get request and convert response to readable object
     def setup
          @client = HTTPClient.new "https://api.pactrak.com/v1/tlc/us"
          @resp = @client.send_request "get"
          @ro = @client.to_json @resp
          @hdr = @client.response_headers    
     end

     def test_perform_all
          assert_equal 200, @client.response_code, "The response code is not 200"
          assert_equal "OK", @client.response_message, "The response message is not correct." 
          refute_nil @resp, "The response object is nil/empty '#{ @resp }'"
          assert_equal 200, @ro.code, "Could not read / json ostruct object '#{ @ro }'" 
          assert_includes @hdr.keys, "access-control-allow-methods", "the expected header is not included"
     end
=begin
     def response_code_test
          print "Response code test...."
          assert_equal "200", @client.response_code, "The response code is not 200"          
          puts "Done".
     end  

     def response_message_test
          print "Response message test...."
          assert_equal "OK", @client.response_message, "The response message is not correct."  
          puts "Done".
     end  

     def response_is_not_empty_test
          print "Response body is not empty...."
          refute_nil @resp, "The response object is nil/empty '#{ @resp }'"
          puts "Done."
     end

     def json_is_valid_test
          print "JSON Object valid...."
          assert_equal 200, @ro.code, "Could not read / json ostruct object '#{ @ro }'"  
          puts "Done."      
     end

     def headers_exists_test
          print "Headers exists?...."
          #puts "Headers: #{ @hdr.inspect }"
          assert_includes @hdr.keys, "access-control-allow-methods", "the expected header is not included"     
          puts "Done."
     end
=end
end
