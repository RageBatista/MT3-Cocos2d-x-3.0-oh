require "utils.tableutil"
CTeamRollMelon = {}
CTeamRollMelon.__index = CTeamRollMelon



CTeamRollMelon.PROTOCOL_TYPE = 794523

function CTeamRollMelon.Create()
	print("enter CTeamRollMelon create")
	return CTeamRollMelon:new()
end
function CTeamRollMelon:new()
	local self = {}
	setmetatable(self, CTeamRollMelon)
	self.type = self.PROTOCOL_TYPE
	self.melonid = 0
	self.status = 0

	return self
end
function CTeamRollMelon:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTeamRollMelon:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.melonid)
	_os_:marshal_int32(self.status)
	return _os_
end

function CTeamRollMelon:unmarshal(_os_)
	self.melonid = _os_:unmarshal_int64()
	self.status = _os_:unmarshal_int32()
	return _os_
end

return CTeamRollMelon
