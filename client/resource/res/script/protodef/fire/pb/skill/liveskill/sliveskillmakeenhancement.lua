require "utils.tableutil"
SLiveSkillMakeEnhancement = {}
SLiveSkillMakeEnhancement.__index = SLiveSkillMakeEnhancement



SLiveSkillMakeEnhancement.PROTOCOL_TYPE = 800526

function SLiveSkillMakeEnhancement.Create()
	print("enter SLiveSkillMakeEnhancement create")
	return SLiveSkillMakeEnhancement:new()
end
function SLiveSkillMakeEnhancement:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeEnhancement)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SLiveSkillMakeEnhancement:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeEnhancement:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SLiveSkillMakeEnhancement:unmarshal(_os_)
	return _os_
end

return SLiveSkillMakeEnhancement
