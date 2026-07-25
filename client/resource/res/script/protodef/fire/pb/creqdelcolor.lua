require "utils.tableutil"
CReqDelColor = {}
CReqDelColor.__index = CReqDelColor



CReqDelColor.PROTOCOL_TYPE = 786536

function CReqDelColor.Create()
	print("enter CReqDelColor create")
	return CReqDelColor:new()
end
function CReqDelColor:new()
	local self = {}
	setmetatable(self, CReqDelColor)
	self.type = self.PROTOCOL_TYPE
	self.removeindex = 0

	return self
end
function CReqDelColor:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqDelColor:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.removeindex)
	return _os_
end

function CReqDelColor:unmarshal(_os_)
	self.removeindex = _os_:unmarshal_int32()
	return _os_
end

return CReqDelColor
