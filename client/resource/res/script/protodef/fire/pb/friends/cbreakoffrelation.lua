require "utils.tableutil"
CBreakOffRelation = {}
CBreakOffRelation.__index = CBreakOffRelation



CBreakOffRelation.PROTOCOL_TYPE = 806437

function CBreakOffRelation.Create()
	print("enter CBreakOffRelation create")
	return CBreakOffRelation:new()
end
function CBreakOffRelation:new()
	local self = {}
	setmetatable(self, CBreakOffRelation)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CBreakOffRelation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBreakOffRelation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CBreakOffRelation:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CBreakOffRelation
