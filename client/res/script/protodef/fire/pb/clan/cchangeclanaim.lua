require "utils.tableutil"
CChangeClanAim = {}
CChangeClanAim.__index = CChangeClanAim



CChangeClanAim.PROTOCOL_TYPE = 808459

function CChangeClanAim.Create()
	print("enter CChangeClanAim create")
	return CChangeClanAim:new()
end
function CChangeClanAim:new()
	local self = {}
	setmetatable(self, CChangeClanAim)
	self.type = self.PROTOCOL_TYPE
	self.newaim = "" 

	return self
end
function CChangeClanAim:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeClanAim:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.newaim)
	return _os_
end

function CChangeClanAim:unmarshal(_os_)
	self.newaim = _os_:unmarshal_wstring(self.newaim)
	return _os_
end

return CChangeClanAim
