require "utils.tableutil"
COpenChest = {}
COpenChest.__index = COpenChest



COpenChest.PROTOCOL_TYPE = 795522

function COpenChest.Create()
	print("enter COpenChest create")
	return COpenChest:new()
end
function COpenChest:new()
	local self = {}
	setmetatable(self, COpenChest)
	self.type = self.PROTOCOL_TYPE
	self.chestnpckey = 0

	return self
end
function COpenChest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenChest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.chestnpckey)
	return _os_
end

function COpenChest:unmarshal(_os_)
	self.chestnpckey = _os_:unmarshal_int64()
	return _os_
end

return COpenChest
