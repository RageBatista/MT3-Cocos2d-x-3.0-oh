require "utils.tableutil"
ParticleSkill = {}
ParticleSkill.__index = ParticleSkill


function ParticleSkill:new()
	local self = {}
	setmetatable(self, ParticleSkill)
	self.id = 0
	self.level = 0
	self.maxlevel = 0
	self.exp = 0
	self.effects = {}
	self.nexteffect = {}

	return self
end
function ParticleSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.maxlevel)
	_os_:marshal_int32(self.exp)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.effects))
	for k,v in pairs(self.effects) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.nexteffect))
	for k,v in pairs(self.nexteffect) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end

	return _os_
end

function ParticleSkill:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.maxlevel = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_effects=0,_os_null_effects
	_os_null_effects, sizeof_effects = _os_: uncompact_uint32(sizeof_effects)
	for k = 1,sizeof_effects do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.effects[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_nexteffect=0,_os_null_nexteffect
	_os_null_nexteffect, sizeof_nexteffect = _os_: uncompact_uint32(sizeof_nexteffect)
	for k = 1,sizeof_nexteffect do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.nexteffect[newkey] = newvalue
	end
	return _os_
end

return ParticleSkill
