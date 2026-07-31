require "utils.tableutil"
CLiveSkillMakeFarm = {}
CLiveSkillMakeFarm.__index = CLiveSkillMakeFarm



CLiveSkillMakeFarm.PROTOCOL_TYPE = 800527

function CLiveSkillMakeFarm.Create()
	print("enter CLiveSkillMakeFarm create")
	return CLiveSkillMakeFarm:new()
end
function CLiveSkillMakeFarm:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeFarm)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLiveSkillMakeFarm:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeFarm:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLiveSkillMakeFarm:unmarshal(_os_)
	return _os_
end

return CLiveSkillMakeFarm
