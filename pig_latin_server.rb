require 'socket'
require 'net/http'
require 'nokogiri'
require_relative 'my_string'
require 'pry'

server = TCPServer.new(8080)

loop do
  client = server.accept
  request = client.gets
  
  path = request.split('?').first.split(' ').last
  params_string = request.split('?').last.split(' ').first
  
  params = params_string.split('&')
    .map { |str| str.split('=') }
    .select { |arr| arr.length == 2 }
    .to_h
  
  host = params['host']
  
  if host.nil?
    client.puts 'Host must be in the query string!'
  else
    uri = URI.parse(host)
    if uri.scheme.nil?
      uri.scheme = 'http'
      uri.host = uri.path
      uri.path = ''  
    end
    uri = URI.join(uri.to_s, path)
    
    request  = Net::HTTP::Get.new(uri.request_uri)
    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
    doc = Nokogiri::HTML(response.body)
    
    doc.search('//text()').select { |node| node.name == 'text' }.each do |element|
      element.content = MyString.new(element.text).to_pig_latin
    end
        
    client.puts doc.to_html
  end
  client.close
end

# would make it work for HTML by using Nokogiri, but I'm out of time :(