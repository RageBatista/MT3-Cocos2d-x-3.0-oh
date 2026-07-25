require "utils.tableutil"
ClanSummaryInfo = {}
ClanSummaryInfo.__index = ClanSummaryInfo


function ClanSummaryInfo:new()
	local self = {}
	setmetatable(self, ClanSummaryInfo)
	self.clanid = 0
	self.index = 0
	self.clanname = "" 
	self.membernum = 0
	self.clanlevel = 0
	self.clanmastername = "" 
	self.clanmasterid = 0
	self.oldclanname = "" 
	self.hotellevel = 0

	return self
end
function ClanSummaryInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	_os_:marshal_int32(self.index)
	_os_:marshal_wstring(self.clanname)
	_os_:marshal_int32(self.membernum)
	_os_:marshal_int32(self.clanlevel)
	_os_:marshal_wstring(self.clanmastername)
	_os_:marshal_int64(self.clanmasterid)
	_os_:marshal_wstring(self.oldclanname)
	_os_:marshal_int32(self.hotellevel)
	return _os_
end

function ClanSummaryInfo:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	self.index = _os_:unmarshal_int32()
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	self.membernum = _os_:unmarshal_int32()
	self.clanlevel = _os_:unmarshal_int32()
	self.clanmastername = _os_:unmarshal_wstring(self.clanmastername)
	self.clanmasterid = _os_:unmarshal_int64()
	self.oldclanname = _os_:unmarshal_wstring(self.oldclanname)
	self.hotellevel = _os_:unmarshal_int32()
	return _os_
end

return ClanSummaryInfo
