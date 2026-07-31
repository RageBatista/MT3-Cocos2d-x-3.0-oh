require "utils.tableutil"
CRuneRequestView = {}
CRuneRequestView.__index = CRuneRequestView



CRuneRequestView.PROTOCOL_TYPE = 808515

function CRuneRequestView.Create()
	print("enter CRuneRequestView create")
	return CRuneRequestView:new()
end
function CRuneRequestView:new()
	local self = {}
	setmetatable(self, CRuneRequestView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRuneRequestView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRuneRequestView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRuneRequestView:unmarshal(_os_)
	return _os_
end

return CRuneRequestView
