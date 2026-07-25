require "utils.tableutil"
SBreakOffRelation = {}
SBreakOffRelation.__index = SBreakOffRelation



SBreakOffRelation.PROTOCOL_TYPE = 806438

function SBreakOffRelation.Create()
	print("enter SBreakOffRelation create")
	return SBreakOffRelation:new()
end
function SBreakOffRelation:new()
	local self = {}
	setmetatable(self, SBreakOffRelation)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SBreakOffRelation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBreakOffRelation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SBreakOffRelation:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SBreakOffRelation
