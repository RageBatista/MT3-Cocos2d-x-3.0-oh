require "utils.tableutil"
CUpdaetAssistSkillLevel = {}
CUpdaetAssistSkillLevel.__index = CUpdaetAssistSkillLevel



CUpdaetAssistSkillLevel.PROTOCOL_TYPE = 800438

function CUpdaetAssistSkillLevel.Create()
	print("enter CUpdaetAssistSkillLevel create")
	return CUpdaetAssistSkillLevel:new()
end
function CUpdaetAssistSkillLevel:new()
	local self = {}
	setmetatable(self, CUpdaetAssistSkillLevel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.id = 0

	return self
end
function CUpdaetAssistSkillLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUpdaetAssistSkillLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.id)
	return _os_
end

function CUpdaetAssistSkillLevel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CUpdaetAssistSkillLevel
