require "utils.tableutil"
SBattleFieldInfo = {}
SBattleFieldInfo.__index = SBattleFieldInfo



SBattleFieldInfo.PROTOCOL_TYPE = 808540

function SBattleFieldInfo.Create()
	print("enter SBattleFieldInfo create")
	return SBattleFieldInfo:new()
end
function SBattleFieldInfo:new()
	local self = {}
	setmetatable(self, SBattleFieldInfo)
	self.type = self.PROTOCOL_TYPE
	self.clanname1 = "" 
	self.clanname2 = "" 
	self.clanid1 = 0
	self.clanid2 = 0

	return self
end
function SBattleFieldInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBattleFieldInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.clanname1)
	_os_:marshal_wstring(self.clanname2)
	_os_:marshal_int64(self.clanid1)
	_os_:marshal_int64(self.clanid2)
	return _os_
end

function SBattleFieldInfo:unmarshal(_os_)
	self.clanname1 = _os_:unmarshal_wstring(self.clanname1)
	self.clanname2 = _os_:unmarshal_wstring(self.clanname2)
	self.clanid1 = _os_:unmarshal_int64()
	self.clanid2 = _os_:unmarshal_int64()
	return _os_
end

return SBattleFieldInfo
