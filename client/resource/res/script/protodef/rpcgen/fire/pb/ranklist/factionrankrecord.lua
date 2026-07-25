require "utils.tableutil"
FactionRankRecord = {}
FactionRankRecord.__index = FactionRankRecord


function FactionRankRecord:new()
	local self = {}
	setmetatable(self, FactionRankRecord)
	self.rank = 0
	self.factionname = "" 
	self.mastername = "" 
	self.level = 0
	self.camp = 0
	self.factionkey = 0

	return self
end
function FactionRankRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_wstring(self.factionname)
	_os_:marshal_wstring(self.mastername)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.camp)
	_os_:marshal_int64(self.factionkey)
	return _os_
end

function FactionRankRecord:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	self.mastername = _os_:unmarshal_wstring(self.mastername)
	self.level = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_int32()
	self.factionkey = _os_:unmarshal_int64()
	return _os_
end

return FactionRankRecord
