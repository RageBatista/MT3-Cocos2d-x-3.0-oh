require "utils.tableutil"
CCallbackMember = {}
CCallbackMember.__index = CCallbackMember



CCallbackMember.PROTOCOL_TYPE = 794443

function CCallbackMember.Create()
	print("enter CCallbackMember create")
	return CCallbackMember:new()
end
function CCallbackMember:new()
	local self = {}
	setmetatable(self, CCallbackMember)
	self.type = self.PROTOCOL_TYPE
	self.memberid = 0

	return self
end
function CCallbackMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCallbackMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberid)
	return _os_
end

function CCallbackMember:unmarshal(_os_)
	self.memberid = _os_:unmarshal_int64()
	return _os_
end

return CCallbackMember
