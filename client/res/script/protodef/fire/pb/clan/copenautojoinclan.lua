require "utils.tableutil"
COpenAutoJoinClan = {}
COpenAutoJoinClan.__index = COpenAutoJoinClan



COpenAutoJoinClan.PROTOCOL_TYPE = 808498

function COpenAutoJoinClan.Create()
	print("enter COpenAutoJoinClan create")
	return COpenAutoJoinClan:new()
end
function COpenAutoJoinClan:new()
	local self = {}
	setmetatable(self, COpenAutoJoinClan)
	self.type = self.PROTOCOL_TYPE
	self.autostate = 0
	self.requestlevel = 0

	return self
end
function COpenAutoJoinClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenAutoJoinClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.autostate)
	_os_:marshal_short(self.requestlevel)
	return _os_
end

function COpenAutoJoinClan:unmarshal(_os_)
	self.autostate = _os_:unmarshal_int32()
	self.requestlevel = _os_:unmarshal_short()
	return _os_
end

return COpenAutoJoinClan
