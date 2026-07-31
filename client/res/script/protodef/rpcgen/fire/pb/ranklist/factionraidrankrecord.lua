require "utils.tableutil"
FactionRaidRankRecord = {}
FactionRaidRankRecord.__index = FactionRaidRankRecord


function FactionRaidRankRecord:new()
	local self = {}
	setmetatable(self, FactionRaidRankRecord)
	self.rank = 0
	self.factionid = 0
	self.factionname = "" 
	self.progressstime = 0
	self.progresss = 0
	self.factionmonstername = "" 
	self.factioncopyname = "" 
	self.bosshp = 0

	return self
end
function FactionRaidRankRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.factionid)
	_os_:marshal_wstring(self.factionname)
	_os_:marshal_int64(self.progressstime)
	_os_:marshal_int32(self.progresss)
	_os_:marshal_wstring(self.factionmonstername)
	_os_:marshal_wstring(self.factioncopyname)
	_os_:marshal_float(self.bosshp)
	return _os_
end

function FactionRaidRankRecord:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.factionid = _os_:unmarshal_int64()
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	self.progressstime = _os_:unmarshal_int64()
	self.progresss = _os_:unmarshal_int32()
	self.factionmonstername = _os_:unmarshal_wstring(self.factionmonstername)
	self.factioncopyname = _os_:unmarshal_wstring(self.factioncopyname)
	self.bosshp = _os_:unmarshal_float()
	return _os_
end

return FactionRaidRankRecord
