require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.pvp3.pvp3rolesinglematch"
SPvP3MatchResult = {}
SPvP3MatchResult.__index = SPvP3MatchResult



SPvP3MatchResult.PROTOCOL_TYPE = 793645

function SPvP3MatchResult.Create()
	print("enter SPvP3MatchResult create")
	return SPvP3MatchResult:new()
end
function SPvP3MatchResult:new()
	local self = {}
	setmetatable(self, SPvP3MatchResult)
	self.type = self.PROTOCOL_TYPE
	self.targets = {}

	return self
end
function SPvP3MatchResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP3MatchResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.targets))
	for k,v in ipairs(self.targets) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPvP3MatchResult:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_targets=0 ,_os_null_targets
	_os_null_targets, sizeof_targets = _os_: uncompact_uint32(sizeof_targets)
	for k = 1,sizeof_targets do
		----------------unmarshal bean
		self.targets[k]=PvP3RoleSingleMatch:new()

		self.targets[k]:unmarshal(_os_)

	end
	return _os_
end

return SPvP3MatchResult
