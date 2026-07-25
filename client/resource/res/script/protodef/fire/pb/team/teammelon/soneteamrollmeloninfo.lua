require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teammelon.rolerollinfo"
SOneTeamRollMelonInfo = {}
SOneTeamRollMelonInfo.__index = SOneTeamRollMelonInfo



SOneTeamRollMelonInfo.PROTOCOL_TYPE = 794526

function SOneTeamRollMelonInfo.Create()
	print("enter SOneTeamRollMelonInfo create")
	return SOneTeamRollMelonInfo:new()
end
function SOneTeamRollMelonInfo:new()
	local self = {}
	setmetatable(self, SOneTeamRollMelonInfo)
	self.type = self.PROTOCOL_TYPE
	self.melonid = 0
	self.itemid = 0
	self.rollinfo = RoleRollInfo:new()

	return self
end
function SOneTeamRollMelonInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOneTeamRollMelonInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.melonid)
	_os_:marshal_int32(self.itemid)
	----------------marshal bean
	self.rollinfo:marshal(_os_) 
	return _os_
end

function SOneTeamRollMelonInfo:unmarshal(_os_)
	self.melonid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.rollinfo:unmarshal(_os_)

	return _os_
end

return SOneTeamRollMelonInfo
