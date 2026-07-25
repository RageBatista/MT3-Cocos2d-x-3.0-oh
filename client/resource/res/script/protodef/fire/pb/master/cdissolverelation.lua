require "utils.tableutil"
CDissolveRelation = {}
CDissolveRelation.__index = CDissolveRelation



CDissolveRelation.PROTOCOL_TYPE = 816449

function CDissolveRelation.Create()
	print("enter CDissolveRelation create")
	return CDissolveRelation:new()
end
function CDissolveRelation:new()
	local self = {}
	setmetatable(self, CDissolveRelation)
	self.type = self.PROTOCOL_TYPE
	self.relation = 0
	self.playerid = 0

	return self
end
function CDissolveRelation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDissolveRelation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.relation)
	_os_:marshal_int64(self.playerid)
	return _os_
end

function CDissolveRelation:unmarshal(_os_)
	self.relation = _os_:unmarshal_int32()
	self.playerid = _os_:unmarshal_int64()
	return _os_
end

return CDissolveRelation
