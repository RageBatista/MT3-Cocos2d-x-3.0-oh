require "utils.tableutil"
CChangeClanName = {}
CChangeClanName.__index = CChangeClanName



CChangeClanName.PROTOCOL_TYPE = 808484

function CChangeClanName.Create()
	print("enter CChangeClanName create")
	return CChangeClanName:new()
end
function CChangeClanName:new()
	local self = {}
	setmetatable(self, CChangeClanName)
	self.type = self.PROTOCOL_TYPE
	self.newname = "" 

	return self
end
function CChangeClanName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeClanName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.newname)
	return _os_
end

function CChangeClanName:unmarshal(_os_)
	self.newname = _os_:unmarshal_wstring(self.newname)
	return _os_
end

return CChangeClanName
