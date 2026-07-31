require "utils.tableutil"
SSendPrenticeOnLineState = {}
SSendPrenticeOnLineState.__index = SSendPrenticeOnLineState



SSendPrenticeOnLineState.PROTOCOL_TYPE = 816472

function SSendPrenticeOnLineState.Create()
	print("enter SSendPrenticeOnLineState create")
	return SSendPrenticeOnLineState:new()
end
function SSendPrenticeOnLineState:new()
	local self = {}
	setmetatable(self, SSendPrenticeOnLineState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.lastofflinetime = 0
	self.onlinestate = 0

	return self
end
function SSendPrenticeOnLineState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendPrenticeOnLineState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int64(self.lastofflinetime)
	_os_:marshal_char(self.onlinestate)
	return _os_
end

function SSendPrenticeOnLineState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.lastofflinetime = _os_:unmarshal_int64()
	self.onlinestate = _os_:unmarshal_char()
	return _os_
end

return SSendPrenticeOnLineState
