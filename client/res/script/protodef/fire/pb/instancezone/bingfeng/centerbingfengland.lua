require "utils.tableutil"
CEnterBingFengLand = {}
CEnterBingFengLand.__index = CEnterBingFengLand



CEnterBingFengLand.PROTOCOL_TYPE = 804553

function CEnterBingFengLand.Create()
	print("enter CEnterBingFengLand create")
	return CEnterBingFengLand:new()
end
function CEnterBingFengLand:new()
	local self = {}
	setmetatable(self, CEnterBingFengLand)
	self.type = self.PROTOCOL_TYPE
	self.landid = 0
	self.stage = 0

	return self
end
function CEnterBingFengLand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEnterBingFengLand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.landid)
	_os_:marshal_int32(self.stage)
	return _os_
end

function CEnterBingFengLand:unmarshal(_os_)
	self.landid = _os_:unmarshal_int32()
	self.stage = _os_:unmarshal_int32()
	return _os_
end

return CEnterBingFengLand
