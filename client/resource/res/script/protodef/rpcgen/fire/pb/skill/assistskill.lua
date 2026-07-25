require "utils.tableutil"
AssistSkill = {}
AssistSkill.__index = AssistSkill


function AssistSkill:new()
	local self = {}
	setmetatable(self, AssistSkill)
	self.id = 0
	self.level = 0
	self.exp = 0

	return self
end
function AssistSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.exp)
	return _os_
end

function AssistSkill:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int32()
	return _os_
end

return AssistSkill
