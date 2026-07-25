require "utils.tableutil"
LiveSkill = {}
LiveSkill.__index = LiveSkill


function LiveSkill:new()
	local self = {}
	setmetatable(self, LiveSkill)
	self.id = 0
	self.level = 0

	return self
end
function LiveSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.level)
	return _os_
end

function LiveSkill:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	return _os_
end

return LiveSkill
