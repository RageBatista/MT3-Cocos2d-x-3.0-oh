require "utils.tableutil"
require "protodef.rpcgen.fire.pb.skill.assistskill"
SUpdateAssistSkill = {}
SUpdateAssistSkill.__index = SUpdateAssistSkill



SUpdateAssistSkill.PROTOCOL_TYPE = 800439

function SUpdateAssistSkill.Create()
	print("enter SUpdateAssistSkill create")
	return SUpdateAssistSkill:new()
end
function SUpdateAssistSkill:new()
	local self = {}
	setmetatable(self, SUpdateAssistSkill)
	self.type = self.PROTOCOL_TYPE
	self.assistskill = AssistSkill:new()

	return self
end
function SUpdateAssistSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateAssistSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.assistskill:marshal(_os_) 
	return _os_
end

function SUpdateAssistSkill:unmarshal(_os_)
	----------------unmarshal bean

	self.assistskill:unmarshal(_os_)

	return _os_
end

return SUpdateAssistSkill
