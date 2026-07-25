require "utils.tableutil"
SDefineTeam = {}
SDefineTeam.__index = SDefineTeam



SDefineTeam.PROTOCOL_TYPE = 805547

function SDefineTeam.Create()
	print("enter SDefineTeam create")
	return SDefineTeam:new()
end
function SDefineTeam:new()
	local self = {}
	setmetatable(self, SDefineTeam)
	self.type = self.PROTOCOL_TYPE
	self.instid = 0
	self.tlstep = 0
	self.mystep = 0

	return self
end
function SDefineTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDefineTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.instid)
	_os_:marshal_int32(self.tlstep)
	_os_:marshal_int32(self.mystep)
	return _os_
end

function SDefineTeam:unmarshal(_os_)
	self.instid = _os_:unmarshal_int32()
	self.tlstep = _os_:unmarshal_int32()
	self.mystep = _os_:unmarshal_int32()
	return _os_
end

return SDefineTeam
