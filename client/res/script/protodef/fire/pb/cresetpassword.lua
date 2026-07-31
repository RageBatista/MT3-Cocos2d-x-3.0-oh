require "utils.tableutil"
CResetPassword = {}
CResetPassword.__index = CResetPassword



CResetPassword.PROTOCOL_TYPE = 786566

function CResetPassword.Create()
	print("enter CResetPassword create")
	return CResetPassword:new()
end
function CResetPassword:new()
	local self = {}
	setmetatable(self, CResetPassword)
	self.type = self.PROTOCOL_TYPE
	self.initpd = "" 
	self.newtpd = "" 
	self.repeatpd = "" 

	return self
end
function CResetPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CResetPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.initpd)
	_os_:marshal_wstring(self.newtpd)
	_os_:marshal_wstring(self.repeatpd)
	return _os_
end

function CResetPassword:unmarshal(_os_)
	self.initpd = _os_:unmarshal_wstring(self.initpd)
	self.newtpd = _os_:unmarshal_wstring(self.newtpd)
	self.repeatpd = _os_:unmarshal_wstring(self.repeatpd)
	return _os_
end

return CResetPassword
