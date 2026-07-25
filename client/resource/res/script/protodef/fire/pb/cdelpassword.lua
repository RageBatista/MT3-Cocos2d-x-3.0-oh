require "utils.tableutil"
CDelPassword = {}
CDelPassword.__index = CDelPassword



CDelPassword.PROTOCOL_TYPE = 786568

function CDelPassword.Create()
	print("enter CDelPassword create")
	return CDelPassword:new()
end
function CDelPassword:new()
	local self = {}
	setmetatable(self, CDelPassword)
	self.type = self.PROTOCOL_TYPE
	self.initpd = "" 
	self.repeatpd = "" 

	return self
end
function CDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.initpd)
	_os_:marshal_wstring(self.repeatpd)
	return _os_
end

function CDelPassword:unmarshal(_os_)
	self.initpd = _os_:unmarshal_wstring(self.initpd)
	self.repeatpd = _os_:unmarshal_wstring(self.repeatpd)
	return _os_
end

return CDelPassword
