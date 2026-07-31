require "utils.tableutil"
CLiveSkillMakeEnhancement = {}
CLiveSkillMakeEnhancement.__index = CLiveSkillMakeEnhancement



CLiveSkillMakeEnhancement.PROTOCOL_TYPE = 800525

function CLiveSkillMakeEnhancement.Create()
	print("enter CLiveSkillMakeEnhancement create")
	return CLiveSkillMakeEnhancement:new()
end
function CLiveSkillMakeEnhancement:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeEnhancement)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLiveSkillMakeEnhancement:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeEnhancement:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLiveSkillMakeEnhancement:unmarshal(_os_)
	return _os_
end

return CLiveSkillMakeEnhancement
