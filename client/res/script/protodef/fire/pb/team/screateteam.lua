require "utils.tableutil"
SCreateTeam = {}
SCreateTeam.__index = SCreateTeam



SCreateTeam.PROTOCOL_TYPE = 794434

function SCreateTeam.Create()
	print("enter SCreateTeam create")
	return SCreateTeam:new()
end
function SCreateTeam:new()
	local self = {}
	setmetatable(self, SCreateTeam)
	self.type = self.PROTOCOL_TYPE
	self.teamid = 0
	self.formation = 0
	self.teamstate = 0
	self.smapid = 0

	return self
end
function SCreateTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCreateTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.teamid)
	_os_:marshal_int32(self.formation)
	_os_:marshal_int32(self.teamstate)
	_os_:marshal_int32(self.smapid)
	return _os_
end

function SCreateTeam:unmarshal(_os_)
	self.teamid = _os_:unmarshal_int64()
	self.formation = _os_:unmarshal_int32()
	self.teamstate = _os_:unmarshal_int32()
	self.smapid = _os_:unmarshal_int32()
	return _os_
end

return SCreateTeam
