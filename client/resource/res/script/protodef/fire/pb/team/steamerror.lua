require "utils.tableutil"
STeamError = {}
STeamError.__index = STeamError



STeamError.PROTOCOL_TYPE = 794468

function STeamError.Create()
	print("enter STeamError create")
	return STeamError:new()
end
function STeamError:new()
	local self = {}
	setmetatable(self, STeamError)
	self.type = self.PROTOCOL_TYPE
	self.teamerror = 0

	return self
end
function STeamError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STeamError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.teamerror)
	return _os_
end

function STeamError:unmarshal(_os_)
	self.teamerror = _os_:unmarshal_int32()
	return _os_
end

return STeamError
