require "utils.tableutil"
SendRoleInfo_Rep = {}
SendRoleInfo_Rep.__index = SendRoleInfo_Rep



SendRoleInfo_Rep.PROTOCOL_TYPE = 819065

function SendRoleInfo_Rep.Create()
	print("enter SendRoleInfo_Rep create")
	return SendRoleInfo_Rep:new()
end
function SendRoleInfo_Rep:new()
	local self = {}
	setmetatable(self, SendRoleInfo_Rep)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.myzoneid = 0
	self.flag = 0

	return self
end
function SendRoleInfo_Rep:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SendRoleInfo_Rep:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.myzoneid)
	_os_:marshal_char(self.flag)
	return _os_
end

function SendRoleInfo_Rep:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.myzoneid = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return SendRoleInfo_Rep
