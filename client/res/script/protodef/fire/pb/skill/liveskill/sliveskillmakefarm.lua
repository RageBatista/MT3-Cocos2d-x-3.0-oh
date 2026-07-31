require "utils.tableutil"
SLiveSkillMakeFarm = {}
SLiveSkillMakeFarm.__index = SLiveSkillMakeFarm



SLiveSkillMakeFarm.PROTOCOL_TYPE = 800528

function SLiveSkillMakeFarm.Create()
	print("enter SLiveSkillMakeFarm create")
	return SLiveSkillMakeFarm:new()
end
function SLiveSkillMakeFarm:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeFarm)
	self.type = self.PROTOCOL_TYPE
	self.addgold = 0

	return self
end
function SLiveSkillMakeFarm:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeFarm:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.addgold)
	return _os_
end

function SLiveSkillMakeFarm:unmarshal(_os_)
	self.addgold = _os_:unmarshal_int32()
	return _os_
end

return SLiveSkillMakeFarm
