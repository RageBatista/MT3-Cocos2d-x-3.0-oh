require "utils.tableutil"
CBeginnerTip = {}
CBeginnerTip.__index = CBeginnerTip



CBeginnerTip.PROTOCOL_TYPE = 786457

function CBeginnerTip.Create()
	print("enter CBeginnerTip create")
	return CBeginnerTip:new()
end
function CBeginnerTip:new()
	local self = {}
	setmetatable(self, CBeginnerTip)
	self.type = self.PROTOCOL_TYPE
	self.tipid = 0

	return self
end
function CBeginnerTip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBeginnerTip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.tipid)
	return _os_
end

function CBeginnerTip:unmarshal(_os_)
	self.tipid = _os_:unmarshal_int32()
	return _os_
end

return CBeginnerTip
