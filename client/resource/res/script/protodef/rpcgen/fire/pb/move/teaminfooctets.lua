require "utils.tableutil"
TeamInfoOctets = {}
TeamInfoOctets.__index = TeamInfoOctets


function TeamInfoOctets:new()
	local self = {}
	setmetatable(self, TeamInfoOctets)
	self.teamid = 0
	self.teamindexstate = 0
	self.hugindex = 0
	self.normalnum = 0

	return self
end
function TeamInfoOctets:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.teamid)
	_os_:marshal_char(self.teamindexstate)
	_os_:marshal_char(self.hugindex)
	_os_:marshal_char(self.normalnum)
	return _os_
end

function TeamInfoOctets:unmarshal(_os_)
	self.teamid = _os_:unmarshal_int64()
	self.teamindexstate = _os_:unmarshal_char()
	self.hugindex = _os_:unmarshal_char()
	self.normalnum = _os_:unmarshal_char()
	return _os_
end

return TeamInfoOctets
