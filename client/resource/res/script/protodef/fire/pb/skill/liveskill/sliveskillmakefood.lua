require "utils.tableutil"
SLiveSkillMakeFood = {}
SLiveSkillMakeFood.__index = SLiveSkillMakeFood



SLiveSkillMakeFood.PROTOCOL_TYPE = 800522

function SLiveSkillMakeFood.Create()
	print("enter SLiveSkillMakeFood create")
	return SLiveSkillMakeFood:new()
end
function SLiveSkillMakeFood:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeFood)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.ret = 0

	return self
end
function SLiveSkillMakeFood:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeFood:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.ret)
	return _os_
end

function SLiveSkillMakeFood:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SLiveSkillMakeFood
