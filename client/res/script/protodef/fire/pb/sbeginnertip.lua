require "utils.tableutil"
SBeginnerTip = {}
SBeginnerTip.__index = SBeginnerTip



SBeginnerTip.PROTOCOL_TYPE = 786458

function SBeginnerTip.Create()
	print("enter SBeginnerTip create")
	return SBeginnerTip:new()
end
function SBeginnerTip:new()
	local self = {}
	setmetatable(self, SBeginnerTip)
	self.type = self.PROTOCOL_TYPE
	self.tipid = 0
	self.tipvalue = 0

	return self
end
function SBeginnerTip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginnerTip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.tipid)
	_os_:marshal_int32(self.tipvalue)
	return _os_
end

function SBeginnerTip:unmarshal(_os_)
	self.tipid = _os_:unmarshal_int32()
	self.tipvalue = _os_:unmarshal_int32()
	return _os_
end

return SBeginnerTip
