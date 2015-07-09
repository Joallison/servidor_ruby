require 'socket'
require 'rdbi-driver-sqlite3'
 
socket = UDPSocket.new
socket.bind("", 2100)
dbh = RDBI.connect(:SQLite3, :database => "servidor_dominio.db")
aspas = '"'
reply = nil
loop {
  puts "Conectado"
  s, sender = socket.recvfrom(1024)
  puts s
  solicitacao = s.split
  cliente_ip = sender[3]
  cliente_port = sender[1]
  if solicitacao[0] == "REG"
    if solicitacao[1] != nil && solicitacao[2] != nil
      begin
        puts "RECEBENDO SOLICITACAO DE REGISTRO DE DOMINIO"
    dbh.execute("insert into servidores (dominio, ip) values ( \"#{solicitacao[1]}\", \"#{solicitacao[2]}\")")
    puts " Registro Realizado com Sucesso!"
    socket.send "REGOK", 0 , cliente_ip, cliente_port
      rescue
        puts "O Dominio ja esta registrado"
    socket.send "REGFALHA", 0, cliente_ip, cliente_port
      end
    else
      puts " Falha Inesperada "
      socket.send "FALHA", 0, cliente_ip, cliente_port
    end
  elsif solicitacao[0] == "IP"
    if solicitacao[1] != nil
      puts "Recebendo IP!"
      rs = dbh.execute("select * from servidores where dominio = \"#{solicitacao[1]}\"")
      rs.fetch(:all).each do |row|
      reply = row
    end
    if reply != nil
      puts "Enviando IP"
      socket.send "IPOK #{reply}", 0, cliente_ip, cliente_port
    elsif reply == nil
      puts "Endereco IP nao encontrado"
      socket.send "IPFALHA", 0, cliente_ip, cliente_port
    end
    else
      puts "Falha Inesperada!"
      socket.send "FALHA", 0, cliente_ip, cliente_port
    end
  else
    puts "Falha Inesperada!"
    socket.send "FALHA", 0, cliente_ip, cliente_port    
  end
}
socket.close