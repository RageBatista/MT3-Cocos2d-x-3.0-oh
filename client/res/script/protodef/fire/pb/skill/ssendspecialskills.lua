require "utils.tableutil"
SSendSpecialSkills = {}
SSendSpecialSkills.__index = SSendSpecialSkills



SSendSpecialSkills.PROTOCOL_TYPE = 800443

function SSendSpecialSkills.Create()
	print("enter SSendSpecialSkills create")
	return SSendSpecialSkills:new()
end
function SSendSpecialSkills:new()
	local self = {}
	setmetatable(self, SSendSpecialSkills)
	self.type = self.PROTOCOL_TYPE
	self.skills = {}
	self.effects = {}

	return self
end
function SSendSpecialSkills:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendSpecialSkills:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.skills))
	for k,v in ipairs(self.skills) do
		_os_:marshal_int32(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.effects))
	for k,v in ipairs(self.effects) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SSendSpecialSkills:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_skills=0,_os_null_skills
	_os_null_skills, sizeof_skills = _os_: uncompact_uint32(sizeof_skills)
	for k = 1,sizeof_skills do
		self.skills[k] = _os_:unmarshal_int32()
	end
	----------------unmarshal vector
	local sizeof_effects=0,_os_null_effects
	_os_null_effects, sizeof_effects = _os_: uncompact_uint32(sizeof_effects)
	for k = 1,sizeof_effects do
		self.effects[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SSendSpecialSkills
