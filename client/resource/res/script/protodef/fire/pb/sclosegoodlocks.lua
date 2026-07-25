require "utils.tableutil"
SCloseGoodLocks = {}
SCloseGoodLocks.__index = SCloseGoodLocks



SCloseGoodLocks.PROTOCOL_TYPE = 786579

function SCloseGoodLocks.Create()
	print("enter SCloseGoodLocks create")
	return SCloseGoodLocks:new()
end
function SCloseGoodLocks:new()
	local self = {}
	setmetatable(self, SCloseGoodLocks)
	self.type = self.PROTOCOL_TYPE
	self.status = 0
	self.closetype = 0

	return self
end
function SCloseGoodLocks:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCloseGoodLocks:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	_os_:marshal_char(self.closetype)
	return _os_
end

function SCloseGoodLocks:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	self.closetype = _os_:unmarshal_char()
	return _os_
end

return SCloseGoodLocks
