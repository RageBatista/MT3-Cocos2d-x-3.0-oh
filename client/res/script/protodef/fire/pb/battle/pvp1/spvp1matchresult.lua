require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.pvp1.pvp1rolesinglematch"
SPvP1MatchResult = {}
SPvP1MatchResult.__index = SPvP1MatchResult



SPvP1MatchResult.PROTOCOL_TYPE = 793542

function SPvP1MatchResult.Create()
	print("enter SPvP1MatchResult create")
	return SPvP1MatchResult:new()
end
function SPvP1MatchResult:new()
	local self = {}
	setmetatable(self, SPvP1MatchResult)
	self.type = self.PROTOCOL_TYPE
	self.target = PvP1RoleSingleMatch:new()

	return self
end
function SPvP1MatchResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1MatchResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.target:marshal(_os_) 
	return _os_
end

function SPvP1MatchResult:unmarshal(_os_)
	----------------unmarshal bean

	self.target:unmarshal(_os_)

	return _os_
end

return SPvP1MatchResult
