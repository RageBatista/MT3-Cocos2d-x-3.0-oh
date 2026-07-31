require "utils.tableutil"
SFactionRankInfo = {}
SFactionRankInfo.__index = SFactionRankInfo



SFactionRankInfo.PROTOCOL_TYPE = 810262

function SFactionRankInfo.Create()
	print("enter SFactionRankInfo create")
	return SFactionRankInfo:new()
end
function SFactionRankInfo:new()
	local self = {}
	setmetatable(self, SFactionRankInfo)
	self.type = self.PROTOCOL_TYPE
	self.factionkey = 0
	self.lastname = "" 
	self.title = "" 
	self.factionmasterid = 0

	return self
end
function SFactionRankInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFactionRankInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.factionkey)
	_os_:marshal_wstring(self.lastname)
	_os_:marshal_wstring(self.title)
	_os_:marshal_int64(self.factionmasterid)
	return _os_
end

function SFactionRankInfo:unmarshal(_os_)
	self.factionkey = _os_:unmarshal_int64()
	self.lastname = _os_:unmarshal_wstring(self.lastname)
	self.title = _os_:unmarshal_wstring(self.title)
	self.factionmasterid = _os_:unmarshal_int64()
	return _os_
end

return SFactionRankInfo
