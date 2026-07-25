require "utils.tableutil"
FactionRankRecordEx = {}
FactionRankRecordEx.__index = FactionRankRecordEx


function FactionRankRecordEx:new()
	local self = {}
	setmetatable(self, FactionRankRecordEx)
	self.rank = 0
	self.factionid = 0
	self.factionname = "" 
	self.progressstime = 0
	self.progresss = 0
	self.factionlevel = 0
	self.externdata = 0
	self.hotellevel = 0

	return self
end
function FactionRankRecordEx:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.factionid)
	_os_:marshal_wstring(self.factionname)
	_os_:marshal_int64(self.progressstime)
	_os_:marshal_int32(self.progresss)
	_os_:marshal_int32(self.factionlevel)
	_os_:marshal_int32(self.externdata)
	_os_:marshal_int32(self.hotellevel)
	return _os_
end

function FactionRankRecordEx:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.factionid = _os_:unmarshal_int64()
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	self.progressstime = _os_:unmarshal_int64()
	self.progresss = _os_:unmarshal_int32()
	self.factionlevel = _os_:unmarshal_int32()
	self.externdata = _os_:unmarshal_int32()
	self.hotellevel = _os_:unmarshal_int32()
	return _os_
end

return FactionRankRecordEx
