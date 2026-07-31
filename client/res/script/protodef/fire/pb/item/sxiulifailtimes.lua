require "utils.tableutil"
SXiuLiFailTimes = {}
SXiuLiFailTimes.__index = SXiuLiFailTimes



SXiuLiFailTimes.PROTOCOL_TYPE = 787477

function SXiuLiFailTimes.Create()
	print("enter SXiuLiFailTimes create")
	return SXiuLiFailTimes:new()
end
function SXiuLiFailTimes:new()
	local self = {}
	setmetatable(self, SXiuLiFailTimes)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.failtimes = 0

	return self
end
function SXiuLiFailTimes:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SXiuLiFailTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.failtimes)
	return _os_
end

function SXiuLiFailTimes:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.failtimes = _os_:unmarshal_int32()
	return _os_
end

return SXiuLiFailTimes
