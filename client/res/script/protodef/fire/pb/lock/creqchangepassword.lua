require "utils.tableutil"
CReqChangePassword = {}
CReqChangePassword.__index = CReqChangePassword



CReqChangePassword.PROTOCOL_TYPE = 818937

function CReqChangePassword.Create()
	print("enter CReqChangePassword create")
	return CReqChangePassword:new()
end
function CReqChangePassword:new()
	local self = {}
	setmetatable(self, CReqChangePassword)
	self.type = self.PROTOCOL_TYPE
	self.oldpassword = "" 
	self.newpassword = "" 

	return self
end
function CReqChangePassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqChangePassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.oldpassword)
	_os_:marshal_wstring(self.newpassword)
	return _os_
end

function CReqChangePassword:unmarshal(_os_)
	self.oldpassword = _os_:unmarshal_wstring(self.oldpassword)
	self.newpassword = _os_:unmarshal_wstring(self.newpassword)
	return _os_
end

return CReqChangePassword
