require "utils.tableutil"
CSetPassword = {}
CSetPassword.__index = CSetPassword



CSetPassword.PROTOCOL_TYPE = 786564

function CSetPassword.Create()
	print("enter CSetPassword create")
	return CSetPassword:new()
end
function CSetPassword:new()
	local self = {}
	setmetatable(self, CSetPassword)
	self.type = self.PROTOCOL_TYPE
	self.initpd = "" 
	self.repeatpd = "" 

	return self
end
function CSetPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.initpd)
	_os_:marshal_wstring(self.repeatpd)
	return _os_
end

function CSetPassword:unmarshal(_os_)
	self.initpd = _os_:unmarshal_wstring(self.initpd)
	self.repeatpd = _os_:unmarshal_wstring(self.repeatpd)
	return _os_
end

return CSetPassword
