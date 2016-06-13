require 'socket'
require 'net/http'
require 'nokogiri'

server = TCPServer.new(8080)

def translate_to_pig_latin(sentence)
  encoded_sentence = sentence.encode("UTF-16be", invalid: :replace, replace: '?').encode('UTF-8')
  return '' if encoded_sentence.nil?
  encoded_sentence.split(' ').map { |word| word[1..-1] + word[0] + 'ay' }.join(' ')
end

loop do
  client = server.accept
  request = client.gets
  
  path = request.split('?').first.split(' ').last
  params_string = request.split('?').last.split(' ').first
  
  params = params_string.split('&').map { |str| 
    str.split('=') 
  }.select { |arr| 
    arr.length == 2 
  }.to_h
  
  host = params['host']
  
  if host.nil?
    client.puts ''
  else
    uri = URI.join('http://' + host, path)
    request  = Net::HTTP::Get.new(uri.request_uri)
    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
    nok = Nokogiri::HTML(response.body)
    
    nok.css('*').each do |element|
      element.children.each do |child|
        next if child.name != 'text'
        child.content = translate_to_pig_latin(child.text)
      end
    end
    
    client.puts nok.to_html
  end
  client.close
end

# would make it work for HTML by using Nokogiri, but I'm out of time :(