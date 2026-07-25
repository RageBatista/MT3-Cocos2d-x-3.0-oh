require "utils.tableutil"
SChangeClanName = {}
SChangeClanName.__index = SChangeClanName



SChangeClanName.PROTOCOL_TYPE = 808485

function SChangeClanName.Create()
	print("enter SChangeClanName create")
	return SChangeClanName:new()
end
function SChangeClanName:new()
	local self = {}
	setmetatable(self, SChangeClanName)
	self.type = self.PROTOCOL_TYPE
	self.newname = "" 

	return self
end
function SChangeClanName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeClanName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.newname)
	return _os_
end

function SChangeClanName:unmarshal(_os_)
	self.newname = _os_:unmarshal_wstring(self.newname)
	return _os_
end

return SChangeClanName
