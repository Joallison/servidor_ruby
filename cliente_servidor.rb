require 'socket'
socket = UDPSocket.new
socket.connect('localhost', 2100)
while solicitacao = gets
	socket.puts solicitacao
	resposta, endereco = socket.recvfrom(1024)
	puts resposta
end
socket.close