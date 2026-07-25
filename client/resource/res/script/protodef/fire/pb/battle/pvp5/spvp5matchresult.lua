require "utils.tableutil"
SPvP5MatchResult = {}
SPvP5MatchResult.__index = SPvP5MatchResult



SPvP5MatchResult.PROTOCOL_TYPE = 793669

function SPvP5MatchResult.Create()
	print("enter SPvP5MatchResult create")
	return SPvP5MatchResult:new()
end
function SPvP5MatchResult:new()
	local self = {}
	setmetatable(self, SPvP5MatchResult)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SPvP5MatchResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP5MatchResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SPvP5MatchResult:unmarshal(_os_)
	return _os_
end

return SPvP5MatchResult
