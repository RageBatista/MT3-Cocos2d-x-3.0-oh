require "utils.tableutil"
CPractiseSkill = {}
CPractiseSkill.__index = CPractiseSkill



CPractiseSkill.PROTOCOL_TYPE = 800460

function CPractiseSkill.Create()
	print("enter CPractiseSkill create")
	return CPractiseSkill:new()
end
function CPractiseSkill:new()
	local self = {}
	setmetatable(self, CPractiseSkill)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.skillid = 0
	self.kind = 0

	return self
end
function CPractiseSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPractiseSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.skillid)
	_os_:marshal_char(self.kind)
	return _os_
end

function CPractiseSkill:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.skillid = _os_:unmarshal_int32()
	self.kind = _os_:unmarshal_char()
	return _os_
end

return CPractiseSkill
