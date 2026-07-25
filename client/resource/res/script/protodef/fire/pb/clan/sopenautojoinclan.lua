require "utils.tableutil"
SOpenAutoJoinClan = {}
SOpenAutoJoinClan.__index = SOpenAutoJoinClan



SOpenAutoJoinClan.PROTOCOL_TYPE = 808499

function SOpenAutoJoinClan.Create()
	print("enter SOpenAutoJoinClan create")
	return SOpenAutoJoinClan:new()
end
function SOpenAutoJoinClan:new()
	local self = {}
	setmetatable(self, SOpenAutoJoinClan)
	self.type = self.PROTOCOL_TYPE
	self.autostate = 0
	self.requestlevel = 0

	return self
end
function SOpenAutoJoinClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenAutoJoinClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.autostate)
	_os_:marshal_short(self.requestlevel)
	return _os_
end

function SOpenAutoJoinClan:unmarshal(_os_)
	self.autostate = _os_:unmarshal_int32()
	self.requestlevel = _os_:unmarshal_short()
	return _os_
end

return SOpenAutoJoinClan
