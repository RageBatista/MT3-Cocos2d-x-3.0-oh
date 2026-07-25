require "utils.tableutil"
SSendAssistSkillMaxLevels = {}
SSendAssistSkillMaxLevels.__index = SSendAssistSkillMaxLevels



SSendAssistSkillMaxLevels.PROTOCOL_TYPE = 800440

function SSendAssistSkillMaxLevels.Create()
	print("enter SSendAssistSkillMaxLevels create")
	return SSendAssistSkillMaxLevels:new()
end
function SSendAssistSkillMaxLevels:new()
	local self = {}
	setmetatable(self, SSendAssistSkillMaxLevels)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.maxlevels = {}

	return self
end
function SSendAssistSkillMaxLevels:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendAssistSkillMaxLevels:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.maxlevels))
	for k,v in pairs(self.maxlevels) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SSendAssistSkillMaxLevels:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_maxlevels=0,_os_null_maxlevels
	_os_null_maxlevels, sizeof_maxlevels = _os_: uncompact_uint32(sizeof_maxlevels)
	for k = 1,sizeof_maxlevels do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.maxlevels[newkey] = newvalue
	end
	return _os_
end

return SSendAssistSkillMaxLevels
