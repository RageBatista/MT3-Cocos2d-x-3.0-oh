require "utils.tableutil"
CShenShouChongZhi = {}
CShenShouChongZhi.__index = CShenShouChongZhi



CShenShouChongZhi.PROTOCOL_TYPE = 788529

function CShenShouChongZhi.Create()
	print("enter CShenShouChongZhi create")
	return CShenShouChongZhi:new()
end
function CShenShouChongZhi:new()
	local self = {}
	setmetatable(self, CShenShouChongZhi)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.needpetid = 0

	return self
end
function CShenShouChongZhi:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShenShouChongZhi:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.needpetid)
	return _os_
end

function CShenShouChongZhi:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.needpetid = _os_:unmarshal_int32()
	return _os_
end

return CShenShouChongZhi
