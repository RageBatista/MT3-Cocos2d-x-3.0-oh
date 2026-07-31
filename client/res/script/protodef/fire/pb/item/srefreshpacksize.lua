require "utils.tableutil"
SRefreshPackSize = {}
SRefreshPackSize.__index = SRefreshPackSize



SRefreshPackSize.PROTOCOL_TYPE = 787459

function SRefreshPackSize.Create()
	print("enter SRefreshPackSize create")
	return SRefreshPackSize:new()
end
function SRefreshPackSize:new()
	local self = {}
	setmetatable(self, SRefreshPackSize)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.cap = 0

	return self
end
function SRefreshPackSize:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPackSize:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.cap)
	return _os_
end

function SRefreshPackSize:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.cap = _os_:unmarshal_int32()
	return _os_
end

return SRefreshPackSize
