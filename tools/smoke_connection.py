from ib.opt import connection

print('Connection class:', connection.Connection)
con = connection.Connection.create()
print('Created Connection with host,port,clientId:', con.host, con.port, con.clientId)
print('Has methods (sample):', hasattr(con, 'connect'), hasattr(con, 'placeOrder'))
