require "utils.tableutil"
PvP5RankData = {}
PvP5RankData.__index = PvP5RankData


function PvP5RankData:new()
	local self = {}
	setmetatable(self, PvP5RankData)
	self.rank = 0
	self.roleid = 0
	self.rolename = "" 
	self.score = 0
	self.school = 0

	return self
end
function PvP5RankData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.score)
	_os_:marshal_int32(self.school)
	return _os_
end

function PvP5RankData:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.score = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	return _os_
end

return PvP5RankData
