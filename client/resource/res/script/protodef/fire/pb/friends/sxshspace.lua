require "utils.tableutil"
SXshSpace = {}
SXshSpace.__index = SXshSpace



SXshSpace.PROTOCOL_TYPE = 806648

function SXshSpace.Create()
	print("enter SXshSpace create")
	return SXshSpace:new()
end
function SXshSpace:new()
	local self = {}
	setmetatable(self, SXshSpace)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SXshSpace:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SXshSpace:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function SXshSpace:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return SXshSpace
