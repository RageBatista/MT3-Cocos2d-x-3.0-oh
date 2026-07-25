require "utils.tableutil"
CSetSign = {}
CSetSign.__index = CSetSign



CSetSign.PROTOCOL_TYPE = 806684

function CSetSign.Create()
	print("enter CSetSign create")
	return CSetSign:new()
end
function CSetSign:new()
	local self = {}
	setmetatable(self, CSetSign)
	self.type = self.PROTOCOL_TYPE
	self.signcontent = "" 

	return self
end
function CSetSign:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetSign:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.signcontent)
	return _os_
end

function CSetSign:unmarshal(_os_)
	self.signcontent = _os_:unmarshal_wstring(self.signcontent)
	return _os_
end

return CSetSign
