require "utils.tableutil"
ClanEventInfo = {}
ClanEventInfo.__index = ClanEventInfo


function ClanEventInfo:new()
	local self = {}
	setmetatable(self, ClanEventInfo)
	self.eventtime = "" 
	self.eventinfo = "" 
	self.eventtype = 0
	self.eventvalue = 0

	return self
end
function ClanEventInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.eventtime)
	_os_:marshal_wstring(self.eventinfo)
	_os_:marshal_int32(self.eventtype)
	_os_:marshal_int64(self.eventvalue)
	return _os_
end

function ClanEventInfo:unmarshal(_os_)
	self.eventtime = _os_:unmarshal_wstring(self.eventtime)
	self.eventinfo = _os_:unmarshal_wstring(self.eventinfo)
	self.eventtype = _os_:unmarshal_int32()
	self.eventvalue = _os_:unmarshal_int64()
	return _os_
end

return ClanEventInfo
