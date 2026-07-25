require "utils.tableutil"
CGetInstanceState = {}
CGetInstanceState.__index = CGetInstanceState



CGetInstanceState.PROTOCOL_TYPE = 805472

function CGetInstanceState.Create()
	print("enter CGetInstanceState create")
	return CGetInstanceState:new()
end
function CGetInstanceState:new()
	local self = {}
	setmetatable(self, CGetInstanceState)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetInstanceState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetInstanceState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetInstanceState:unmarshal(_os_)
	return _os_
end

return CGetInstanceState
