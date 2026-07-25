require "utils.tableutil"
SDissolveRelation = {}
SDissolveRelation.__index = SDissolveRelation



SDissolveRelation.PROTOCOL_TYPE = 816450

function SDissolveRelation.Create()
	print("enter SDissolveRelation create")
	return SDissolveRelation:new()
end
function SDissolveRelation:new()
	local self = {}
	setmetatable(self, SDissolveRelation)
	self.type = self.PROTOCOL_TYPE
	self.relation = 0
	self.initiative = 0
	self.playerid = 0

	return self
end
function SDissolveRelation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDissolveRelation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.relation)
	_os_:marshal_int32(self.initiative)
	_os_:marshal_int64(self.playerid)
	return _os_
end

function SDissolveRelation:unmarshal(_os_)
	self.relation = _os_:unmarshal_int32()
	self.initiative = _os_:unmarshal_int32()
	self.playerid = _os_:unmarshal_int64()
	return _os_
end

return SDissolveRelation
