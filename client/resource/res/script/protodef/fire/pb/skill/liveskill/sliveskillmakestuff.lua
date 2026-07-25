require "utils.tableutil"
SLiveSkillMakeStuff = {}
SLiveSkillMakeStuff.__index = SLiveSkillMakeStuff



SLiveSkillMakeStuff.PROTOCOL_TYPE = 800518

function SLiveSkillMakeStuff.Create()
	print("enter SLiveSkillMakeStuff create")
	return SLiveSkillMakeStuff:new()
end
function SLiveSkillMakeStuff:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeStuff)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SLiveSkillMakeStuff:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeStuff:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	return _os_
end

function SLiveSkillMakeStuff:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SLiveSkillMakeStuff
