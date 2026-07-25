require "utils.tableutil"
CCloseGoodLocks = {}
CCloseGoodLocks.__index = CCloseGoodLocks



CCloseGoodLocks.PROTOCOL_TYPE = 786578

function CCloseGoodLocks.Create()
	print("enter CCloseGoodLocks create")
	return CCloseGoodLocks:new()
end
function CCloseGoodLocks:new()
	local self = {}
	setmetatable(self, CCloseGoodLocks)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 
	self.closetype = 0

	return self
end
function CCloseGoodLocks:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCloseGoodLocks:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	_os_:marshal_char(self.closetype)
	return _os_
end

function CCloseGoodLocks:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	self.closetype = _os_:unmarshal_char()
	return _os_
end

return CCloseGoodLocks
