require "utils.tableutil"
SChangeClanAim = {}
SChangeClanAim.__index = SChangeClanAim



SChangeClanAim.PROTOCOL_TYPE = 808460

function SChangeClanAim.Create()
	print("enter SChangeClanAim create")
	return SChangeClanAim:new()
end
function SChangeClanAim:new()
	local self = {}
	setmetatable(self, SChangeClanAim)
	self.type = self.PROTOCOL_TYPE
	self.newaim = "" 

	return self
end
function SChangeClanAim:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeClanAim:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.newaim)
	return _os_
end

function SChangeClanAim:unmarshal(_os_)
	self.newaim = _os_:unmarshal_wstring(self.newaim)
	return _os_
end

return SChangeClanAim
