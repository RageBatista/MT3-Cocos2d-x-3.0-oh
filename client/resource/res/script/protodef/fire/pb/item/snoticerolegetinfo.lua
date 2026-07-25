require "utils.tableutil"
SNoticeRoleGetInfo = {}
SNoticeRoleGetInfo.__index = SNoticeRoleGetInfo



SNoticeRoleGetInfo.PROTOCOL_TYPE = 787711

function SNoticeRoleGetInfo.Create()
	print("enter SNoticeRoleGetInfo create")
	return SNoticeRoleGetInfo:new()
end
function SNoticeRoleGetInfo:new()
	local self = {}
	setmetatable(self, SNoticeRoleGetInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 

	return self
end
function SNoticeRoleGetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNoticeRoleGetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	return _os_
end

function SNoticeRoleGetInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	return _os_
end

return SNoticeRoleGetInfo
