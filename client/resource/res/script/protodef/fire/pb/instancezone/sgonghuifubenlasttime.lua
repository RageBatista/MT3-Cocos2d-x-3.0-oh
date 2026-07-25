require "utils.tableutil"
SGongHuiFuBenLastTime = {}
SGongHuiFuBenLastTime.__index = SGongHuiFuBenLastTime



SGongHuiFuBenLastTime.PROTOCOL_TYPE = 804533

function SGongHuiFuBenLastTime.Create()
	print("enter SGongHuiFuBenLastTime create")
	return SGongHuiFuBenLastTime:new()
end
function SGongHuiFuBenLastTime:new()
	local self = {}
	setmetatable(self, SGongHuiFuBenLastTime)
	self.type = self.PROTOCOL_TYPE
	self.lasttime = 0

	return self
end
function SGongHuiFuBenLastTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGongHuiFuBenLastTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.lasttime)
	return _os_
end

function SGongHuiFuBenLastTime:unmarshal(_os_)
	self.lasttime = _os_:unmarshal_int64()
	return _os_
end

return SGongHuiFuBenLastTime
