require "utils.tableutil"
SReqPointSchemeTime = {}
SReqPointSchemeTime.__index = SReqPointSchemeTime



SReqPointSchemeTime.PROTOCOL_TYPE = 786542

function SReqPointSchemeTime.Create()
	print("enter SReqPointSchemeTime create")
	return SReqPointSchemeTime:new()
end
function SReqPointSchemeTime:new()
	local self = {}
	setmetatable(self, SReqPointSchemeTime)
	self.type = self.PROTOCOL_TYPE
	self.schemetimes = 0

	return self
end
function SReqPointSchemeTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqPointSchemeTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.schemetimes)
	return _os_
end

function SReqPointSchemeTime:unmarshal(_os_)
	self.schemetimes = _os_:unmarshal_int32()
	return _os_
end

return SReqPointSchemeTime
