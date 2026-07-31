require "utils.tableutil"
CUpdateInborn = {}
CUpdateInborn.__index = CUpdateInborn



CUpdateInborn.PROTOCOL_TYPE = 800445

function CUpdateInborn.Create()
	print("enter CUpdateInborn create")
	return CUpdateInborn:new()
end
function CUpdateInborn:new()
	local self = {}
	setmetatable(self, CUpdateInborn)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.flag = 0

	return self
end
function CUpdateInborn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUpdateInborn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_char(self.flag)
	return _os_
end

function CUpdateInborn:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return CUpdateInborn
