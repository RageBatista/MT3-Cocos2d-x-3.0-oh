require "utils.tableutil"
CLiveSkillMakeFood = {}
CLiveSkillMakeFood.__index = CLiveSkillMakeFood



CLiveSkillMakeFood.PROTOCOL_TYPE = 800521

function CLiveSkillMakeFood.Create()
	print("enter CLiveSkillMakeFood create")
	return CLiveSkillMakeFood:new()
end
function CLiveSkillMakeFood:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeFood)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLiveSkillMakeFood:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeFood:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLiveSkillMakeFood:unmarshal(_os_)
	return _os_
end

return CLiveSkillMakeFood
