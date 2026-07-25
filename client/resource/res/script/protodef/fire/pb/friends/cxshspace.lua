require "utils.tableutil"
CXshSpace = {}
CXshSpace.__index = CXshSpace



CXshSpace.PROTOCOL_TYPE = 806647

function CXshSpace.Create()
	print("enter CXshSpace create")
	return CXshSpace:new()
end
function CXshSpace:new()
	local self = {}
	setmetatable(self, CXshSpace)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CXshSpace:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CXshSpace:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CXshSpace:unmarshal(_os_)
	return _os_
end

return CXshSpace
