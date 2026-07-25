require "utils.tableutil"
SRideUpdate = {}
SRideUpdate.__index = SRideUpdate



SRideUpdate.PROTOCOL_TYPE = 787783

function SRideUpdate.Create()
	print("enter SRideUpdate create")
	return SRideUpdate:new()
end
function SRideUpdate:new()
	local self = {}
	setmetatable(self, SRideUpdate)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0
	self.itemid = 0
	self.rideid = 0

	return self
end
function SRideUpdate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRideUpdate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.rideid)
	return _os_
end

function SRideUpdate:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	self.rideid = _os_:unmarshal_int32()
	return _os_
end

return SRideUpdate
