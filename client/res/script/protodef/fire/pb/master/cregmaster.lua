require "utils.tableutil"
CRegMaster = {}
CRegMaster.__index = CRegMaster



CRegMaster.PROTOCOL_TYPE = 816435

function CRegMaster.Create()
	print("enter CRegMaster create")
	return CRegMaster:new()
end
function CRegMaster:new()
	local self = {}
	setmetatable(self, CRegMaster)
	self.type = self.PROTOCOL_TYPE
	self.declaration = "" 

	return self
end
function CRegMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRegMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.declaration)
	return _os_
end

function CRegMaster:unmarshal(_os_)
	self.declaration = _os_:unmarshal_wstring(self.declaration)
	return _os_
end

return CRegMaster
