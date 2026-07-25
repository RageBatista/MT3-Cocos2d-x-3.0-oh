require "utils.tableutil"
CRequestAsApprentice = {}
CRequestAsApprentice.__index = CRequestAsApprentice



CRequestAsApprentice.PROTOCOL_TYPE = 816439

function CRequestAsApprentice.Create()
	print("enter CRequestAsApprentice create")
	return CRequestAsApprentice:new()
end
function CRequestAsApprentice:new()
	local self = {}
	setmetatable(self, CRequestAsApprentice)
	self.type = self.PROTOCOL_TYPE
	self.masterid = 0

	return self
end
function CRequestAsApprentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestAsApprentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.masterid)
	return _os_
end

function CRequestAsApprentice:unmarshal(_os_)
	self.masterid = _os_:unmarshal_int64()
	return _os_
end

return CRequestAsApprentice
