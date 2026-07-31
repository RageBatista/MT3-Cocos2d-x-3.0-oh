require "utils.tableutil"
CRequestPrenticeOnLineState = {}
CRequestPrenticeOnLineState.__index = CRequestPrenticeOnLineState



CRequestPrenticeOnLineState.PROTOCOL_TYPE = 816471

function CRequestPrenticeOnLineState.Create()
	print("enter CRequestPrenticeOnLineState create")
	return CRequestPrenticeOnLineState:new()
end
function CRequestPrenticeOnLineState:new()
	local self = {}
	setmetatable(self, CRequestPrenticeOnLineState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRequestPrenticeOnLineState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestPrenticeOnLineState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRequestPrenticeOnLineState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRequestPrenticeOnLineState
