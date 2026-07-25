require "utils.tableutil"
CExitCopy = {}
CExitCopy.__index = CExitCopy



CExitCopy.PROTOCOL_TYPE = 795668

function CExitCopy.Create()
	print("enter CExitCopy create")
	return CExitCopy:new()
end
function CExitCopy:new()
	local self = {}
	setmetatable(self, CExitCopy)
	self.type = self.PROTOCOL_TYPE
	self.gototype = 0

	return self
end
function CExitCopy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExitCopy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.gototype)
	return _os_
end

function CExitCopy:unmarshal(_os_)
	self.gototype = _os_:unmarshal_char()
	return _os_
end

return CExitCopy
