# references: http://ruby-doc.org/stdlib-2.1.1/libdoc/net/http/rdoc/Net/HTTPHeader.html#method-i-add_field
# import the netHTTP 
require 'net/http'

# uri get the url http headers
uri = URI('http://google.com')

# new request and result the http_readers
http_request = Net::HTTP::Get.new(uri)

# o metodo each_header retorna um map com o nome do header e o conteudo
http_request.each_header { |header,value| puts header + " " + value }
#http_request.set_form_data({"REMOTE_USER" => "siqueira"})
#http_request.set_form_data({"q" => "ruby", "lang" => "en"}, ';')

### add_field adicona um campo novo ou seja um novo HTTP_HEADER no nosso caso o REMOTE_USER 
http_request.add_field 'REMOTE_USER', 'siqueira'

# Com o get_field podemos pegar o conteudo do header REMOTE_USER
puts http_request.get_fields('REMOTE_USER')

# => accept-encoding
# => accept
# => user-agent
# => host    

http_response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(http_request)
end
