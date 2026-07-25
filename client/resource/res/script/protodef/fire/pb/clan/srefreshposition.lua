require "utils.tableutil"
SRefreshPosition = {}
SRefreshPosition.__index = SRefreshPosition



SRefreshPosition.PROTOCOL_TYPE = 808466

function SRefreshPosition.Create()
	print("enter SRefreshPosition create")
	return SRefreshPosition:new()
end
function SRefreshPosition:new()
	local self = {}
	setmetatable(self, SRefreshPosition)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.position = 0

	return self
end
function SRefreshPosition:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPosition:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.position)
	return _os_
end

function SRefreshPosition:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.position = _os_:unmarshal_int32()
	return _os_
end

return SRefreshPosition
