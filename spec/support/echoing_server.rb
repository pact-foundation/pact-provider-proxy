require 'socket'

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  request = ""
  while (line = client.gets) != "\r\n"
    request += line # Prints whatever the client enters on the server's output
  end
  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/plain"
  client.puts "\r\n"
  # Echo back entire request in body
  client.puts request
  client.puts "\r\n"
  client.close
end
