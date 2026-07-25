require "utils.tableutil"
CGetLineState = {}
CGetLineState.__index = CGetLineState



CGetLineState.PROTOCOL_TYPE = 805474

function CGetLineState.Create()
	print("enter CGetLineState create")
	return CGetLineState:new()
end
function CGetLineState:new()
	local self = {}
	setmetatable(self, CGetLineState)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetLineState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetLineState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetLineState:unmarshal(_os_)
	return _os_
end

return CGetLineState
