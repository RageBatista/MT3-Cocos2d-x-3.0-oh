require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.logbean"
SMarketTradeLog = {}
SMarketTradeLog.__index = SMarketTradeLog



SMarketTradeLog.PROTOCOL_TYPE = 810646

function SMarketTradeLog.Create()
	print("enter SMarketTradeLog create")
	return SMarketTradeLog:new()
end
function SMarketTradeLog:new()
	local self = {}
	setmetatable(self, SMarketTradeLog)
	self.type = self.PROTOCOL_TYPE
	self.buylog = {}
	self.salelog = {}

	return self
end
function SMarketTradeLog:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketTradeLog:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.buylog))
	for k,v in ipairs(self.buylog) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.salelog))
	for k,v in ipairs(self.salelog) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SMarketTradeLog:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_buylog=0,_os_null_buylog
	_os_null_buylog, sizeof_buylog = _os_: uncompact_uint32(sizeof_buylog)
	for k = 1,sizeof_buylog do
		----------------unmarshal bean
		self.buylog[k]=LogBean:new()

		self.buylog[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_salelog=0,_os_null_salelog
	_os_null_salelog, sizeof_salelog = _os_: uncompact_uint32(sizeof_salelog)
	for k = 1,sizeof_salelog do
		----------------unmarshal bean
		self.salelog[k]=LogBean:new()

		self.salelog[k]:unmarshal(_os_)

	end
	return _os_
end

return SMarketTradeLog
