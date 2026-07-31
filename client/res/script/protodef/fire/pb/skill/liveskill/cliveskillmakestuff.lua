require "utils.tableutil"
CLiveSkillMakeStuff = {}
CLiveSkillMakeStuff.__index = CLiveSkillMakeStuff



CLiveSkillMakeStuff.PROTOCOL_TYPE = 800517

function CLiveSkillMakeStuff.Create()
	print("enter CLiveSkillMakeStuff create")
	return CLiveSkillMakeStuff:new()
end
function CLiveSkillMakeStuff:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeStuff)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.itemnum = 0

	return self
end
function CLiveSkillMakeStuff:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeStuff:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	return _os_
end

function CLiveSkillMakeStuff:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	return _os_
end

return CLiveSkillMakeStuff
