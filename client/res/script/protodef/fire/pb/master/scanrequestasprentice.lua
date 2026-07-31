require "utils.tableutil"
SCanRequestAsPrentice = {}
SCanRequestAsPrentice.__index = SCanRequestAsPrentice



SCanRequestAsPrentice.PROTOCOL_TYPE = 816462

function SCanRequestAsPrentice.Create()
	print("enter SCanRequestAsPrentice create")
	return SCanRequestAsPrentice:new()
end
function SCanRequestAsPrentice:new()
	local self = {}
	setmetatable(self, SCanRequestAsPrentice)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 

	return self
end
function SCanRequestAsPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCanRequestAsPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	return _os_
end

function SCanRequestAsPrentice:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	return _os_
end

return SCanRequestAsPrentice
