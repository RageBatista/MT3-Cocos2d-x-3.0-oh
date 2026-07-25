require "utils.tableutil"
SLiveSkillMakeDrug = {}
SLiveSkillMakeDrug.__index = SLiveSkillMakeDrug



SLiveSkillMakeDrug.PROTOCOL_TYPE = 800520

function SLiveSkillMakeDrug.Create()
	print("enter SLiveSkillMakeDrug create")
	return SLiveSkillMakeDrug:new()
end
function SLiveSkillMakeDrug:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeDrug)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.ret = 0

	return self
end
function SLiveSkillMakeDrug:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeDrug:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.ret)
	return _os_
end

function SLiveSkillMakeDrug:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SLiveSkillMakeDrug
