require "utils.tableutil"
SItemSign = {}
SItemSign.__index = SItemSign



SItemSign.PROTOCOL_TYPE = 787486

function SItemSign.Create()
	print("enter SItemSign create")
	return SItemSign:new()
end
function SItemSign:new()
	local self = {}
	setmetatable(self, SItemSign)
	self.type = self.PROTOCOL_TYPE
	self.keyinpack = 0
	self.sign = 0
	self.packid = 0

	return self
end
function SItemSign:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemSign:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.sign)
	_os_:marshal_int32(self.packid)
	return _os_
end

function SItemSign:unmarshal(_os_)
	self.keyinpack = _os_:unmarshal_int32()
	self.sign = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_int32()
	return _os_
end

return SItemSign
