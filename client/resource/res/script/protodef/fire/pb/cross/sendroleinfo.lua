require "utils.tableutil"
SendRoleInfo = {}
SendRoleInfo.__index = SendRoleInfo



SendRoleInfo.PROTOCOL_TYPE = 819064

function SendRoleInfo.Create()
	print("enter SendRoleInfo create")
	return SendRoleInfo:new()
end
function SendRoleInfo:new()
	local self = {}
	setmetatable(self, SendRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.myzoneid = 0
	self.userid = 0
	self.roleid = 0
	self.flag = 0
	self.needcleardata = 0

	return self
end
function SendRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SendRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.myzoneid)
	_os_:marshal_int32(self.userid)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.flag)
	_os_:marshal_char(self.needcleardata)
	return _os_
end

function SendRoleInfo:unmarshal(_os_)
	self.myzoneid = _os_:unmarshal_int32()
	self.userid = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.flag = _os_:unmarshal_char()
	self.needcleardata = _os_:unmarshal_char()
	return _os_
end

return SendRoleInfo
