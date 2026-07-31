require "utils.tableutil"
require "protodef.rpcgen.fire.pb.skill.liveskill.liveskill"
SUpdateLearnLiveSkill = {}
SUpdateLearnLiveSkill.__index = SUpdateLearnLiveSkill



SUpdateLearnLiveSkill.PROTOCOL_TYPE = 800516

function SUpdateLearnLiveSkill.Create()
	print("enter SUpdateLearnLiveSkill create")
	return SUpdateLearnLiveSkill:new()
end
function SUpdateLearnLiveSkill:new()
	local self = {}
	setmetatable(self, SUpdateLearnLiveSkill)
	self.type = self.PROTOCOL_TYPE
	self.skill = LiveSkill:new()

	return self
end
function SUpdateLearnLiveSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateLearnLiveSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.skill:marshal(_os_) 
	return _os_
end

function SUpdateLearnLiveSkill:unmarshal(_os_)
	----------------unmarshal bean

	self.skill:unmarshal(_os_)

	return _os_
end

return SUpdateLearnLiveSkill
