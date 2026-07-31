require "utils.tableutil"
SRefreshItemTimeout = {}
SRefreshItemTimeout.__index = SRefreshItemTimeout



SRefreshItemTimeout.PROTOCOL_TYPE = 787438

function SRefreshItemTimeout.Create()
	print("enter SRefreshItemTimeout create")
	return SRefreshItemTimeout:new()
end
function SRefreshItemTimeout:new()
	local self = {}
	setmetatable(self, SRefreshItemTimeout)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.itemkey = 0
	self.timeout = 0

	return self
end
function SRefreshItemTimeout:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshItemTimeout:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int64(self.timeout)
	return _os_
end

function SRefreshItemTimeout:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	self.timeout = _os_:unmarshal_int64()
	return _os_
end

return SRefreshItemTimeout
