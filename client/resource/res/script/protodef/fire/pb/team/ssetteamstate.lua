require "utils.tableutil"
SSetTeamState = {}
SSetTeamState.__index = SSetTeamState



SSetTeamState.PROTOCOL_TYPE = 794484

function SSetTeamState.Create()
	print("enter SSetTeamState create")
	return SSetTeamState:new()
end
function SSetTeamState:new()
	local self = {}
	setmetatable(self, SSetTeamState)
	self.type = self.PROTOCOL_TYPE
	self.state = 0
	self.smapid = 0

	return self
end
function SSetTeamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetTeamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.smapid)
	return _os_
end

function SSetTeamState:unmarshal(_os_)
	self.state = _os_:unmarshal_int32()
	self.smapid = _os_:unmarshal_int32()
	return _os_
end

return SSetTeamState
