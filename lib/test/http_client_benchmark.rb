require_relative '../http_client'
require "minitest/autorun"
require "minitest/benchmark"
require "minitest/pride"
=begin
	https://chriskottom.com/blog/2015/04/minitest-benchmark-an-introduction/
     http://ruby-doc.org/stdlib-trunk/libdoc/minitest/benchmark/rdoc/MiniTest/Unit/TestCase.html
	https://github.com/seattlerb/minitest
=end

class HTTPClientBechmark < Minitest::Benchmark

	def bench_us_tlc
		@client = HTTPClient.new
		@client.url = "http://kanga.ibcinc.com:19000/v1/tlc/us"
		@client.proxy_address = "http://proxy.ibcinc.com:3128"
		assert_performance_constant 0.9999 do |n|
			10.times do
				r = @client.send_request "get"
			end
		end
	end

end
