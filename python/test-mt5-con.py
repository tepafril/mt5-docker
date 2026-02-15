from mt5linux import MetaTrader5
mt5 = MetaTrader5(host='localhost',port=8001)
mt5.initialize()
print(mt5.version())