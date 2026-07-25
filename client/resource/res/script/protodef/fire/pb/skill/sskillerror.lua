require "utils.tableutil"
SSkillError = {}
SSkillError.__index = SSkillError



SSkillError.PROTOCOL_TYPE = 800436

function SSkillError.Create()
	print("enter SSkillError create")
	return SSkillError:new()
end
function SSkillError:new()
	local self = {}
	setmetatable(self, SSkillError)
	self.type = self.PROTOCOL_TYPE
	self.skillerror = 0

	return self
end
function SSkillError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSkillError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.skillerror)
	return _os_
end

function SSkillError:unmarshal(_os_)
	self.skillerror = _os_:unmarshal_int32()
	return _os_
end

return SSkillError
