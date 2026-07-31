require "utils.tableutil"
CAppMaster = {}
CAppMaster.__index = CAppMaster



CAppMaster.PROTOCOL_TYPE = 816485

function CAppMaster.Create()
	print("enter CAppMaster create")
	return CAppMaster:new()
end
function CAppMaster:new()
	local self = {}
	setmetatable(self, CAppMaster)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0

	return self
end
function CAppMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAppMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)
	return _os_
end

function CAppMaster:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return CAppMaster
