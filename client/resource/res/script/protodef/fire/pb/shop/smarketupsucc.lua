require "utils.tableutil"
SMarketUpSucc = {}
SMarketUpSucc.__index = SMarketUpSucc



SMarketUpSucc.PROTOCOL_TYPE = 810654

function SMarketUpSucc.Create()
	print("enter SMarketUpSucc create")
	return SMarketUpSucc:new()
end
function SMarketUpSucc:new()
	local self = {}
	setmetatable(self, SMarketUpSucc)
	self.type = self.PROTOCOL_TYPE
	self.israrity = 0

	return self
end
function SMarketUpSucc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketUpSucc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.israrity)
	return _os_
end

function SMarketUpSucc:unmarshal(_os_)
	self.israrity = _os_:unmarshal_int32()
	return _os_
end

return SMarketUpSucc
