require "utils.tableutil"
SRefreshRoleClan = {}
SRefreshRoleClan.__index = SRefreshRoleClan



SRefreshRoleClan.PROTOCOL_TYPE = 808519

function SRefreshRoleClan.Create()
	print("enter SRefreshRoleClan create")
	return SRefreshRoleClan:new()
end
function SRefreshRoleClan:new()
	local self = {}
	setmetatable(self, SRefreshRoleClan)
	self.type = self.PROTOCOL_TYPE
	self.clankey = 0
	self.clanname = "" 

	return self
end
function SRefreshRoleClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clankey)
	_os_:marshal_wstring(self.clanname)
	return _os_
end

function SRefreshRoleClan:unmarshal(_os_)
	self.clankey = _os_:unmarshal_int64()
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	return _os_
end

return SRefreshRoleClan
