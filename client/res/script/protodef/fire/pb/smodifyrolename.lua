require "utils.tableutil"
SModifyRoleName = {}
SModifyRoleName.__index = SModifyRoleName



SModifyRoleName.PROTOCOL_TYPE = 786507

function SModifyRoleName.Create()
	print("enter SModifyRoleName create")
	return SModifyRoleName:new()
end
function SModifyRoleName:new()
	local self = {}
	setmetatable(self, SModifyRoleName)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.newname = "" 

	return self
end
function SModifyRoleName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SModifyRoleName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.newname)
	return _os_
end

function SModifyRoleName:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.newname = _os_:unmarshal_wstring(self.newname)
	return _os_
end

return SModifyRoleName
