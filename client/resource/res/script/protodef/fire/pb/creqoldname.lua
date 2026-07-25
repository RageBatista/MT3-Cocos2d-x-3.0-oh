require "utils.tableutil"
CReqOldName = {}
CReqOldName.__index = CReqOldName



CReqOldName.PROTOCOL_TYPE = 786520

function CReqOldName.Create()
	print("enter CReqOldName create")
	return CReqOldName:new()
end
function CReqOldName:new()
	local self = {}
	setmetatable(self, CReqOldName)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CReqOldName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqOldName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CReqOldName:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CReqOldName
