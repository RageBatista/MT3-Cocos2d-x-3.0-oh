require "utils.tableutil"
CReqRoleProp = {}
CReqRoleProp.__index = CReqRoleProp



CReqRoleProp.PROTOCOL_TYPE = 786453

function CReqRoleProp.Create()
	print("enter CReqRoleProp create")
	return CReqRoleProp:new()
end
function CReqRoleProp:new()
	local self = {}
	setmetatable(self, CReqRoleProp)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.proptype = 0

	return self
end
function CReqRoleProp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqRoleProp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.proptype)
	return _os_
end

function CReqRoleProp:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.proptype = _os_:unmarshal_int32()
	return _os_
end

return CReqRoleProp
