require "utils.tableutil"
SRankRoleInfo = {}
SRankRoleInfo.__index = SRankRoleInfo



SRankRoleInfo.PROTOCOL_TYPE = 810257

function SRankRoleInfo.Create()
	print("enter SRankRoleInfo create")
	return SRankRoleInfo:new()
end
function SRankRoleInfo:new()
	local self = {}
	setmetatable(self, SRankRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.shape = 0
	self.level = 0
	self.zonghescore = 0
	self.petscore = 0
	self.camp = 0
	self.school = 0
	self.factionname = "" 
	self.rank = 0

	return self
end
function SRankRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRankRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.zonghescore)
	_os_:marshal_int32(self.petscore)
	_os_:marshal_int32(self.camp)
	_os_:marshal_int32(self.school)
	_os_:marshal_wstring(self.factionname)
	_os_:marshal_int32(self.rank)
	return _os_
end

function SRankRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.zonghescore = _os_:unmarshal_int32()
	self.petscore = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	self.rank = _os_:unmarshal_int32()
	return _os_
end

return SRankRoleInfo
