require "utils.tableutil"
CBeginnerTipShowed = {}
CBeginnerTipShowed.__index = CBeginnerTipShowed



CBeginnerTipShowed.PROTOCOL_TYPE = 786459

function CBeginnerTipShowed.Create()
	print("enter CBeginnerTipShowed create")
	return CBeginnerTipShowed:new()
end
function CBeginnerTipShowed:new()
	local self = {}
	setmetatable(self, CBeginnerTipShowed)
	self.type = self.PROTOCOL_TYPE
	self.tipid = 0

	return self
end
function CBeginnerTipShowed:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBeginnerTipShowed:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.tipid)
	return _os_
end

function CBeginnerTipShowed:unmarshal(_os_)
	self.tipid = _os_:unmarshal_int32()
	return _os_
end

return CBeginnerTipShowed
