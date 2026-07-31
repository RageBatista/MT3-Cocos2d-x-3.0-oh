require "utils.tableutil"
SRoleTurn = {}
SRoleTurn.__index = SRoleTurn



SRoleTurn.PROTOCOL_TYPE = 790440

function SRoleTurn.Create()
	print("enter SRoleTurn create")
	return SRoleTurn:new()
end
function SRoleTurn:new()
	local self = {}
	setmetatable(self, SRoleTurn)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.direction = 0

	return self
end
function SRoleTurn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleTurn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.direction)
	return _os_
end

function SRoleTurn:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.direction = _os_:unmarshal_int32()
	return _os_
end

return SRoleTurn
