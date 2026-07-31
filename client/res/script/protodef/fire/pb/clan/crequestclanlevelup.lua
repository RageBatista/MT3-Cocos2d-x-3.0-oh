require "utils.tableutil"
CRequestClanLevelup = {}
CRequestClanLevelup.__index = CRequestClanLevelup



CRequestClanLevelup.PROTOCOL_TYPE = 808472

function CRequestClanLevelup.Create()
	print("enter CRequestClanLevelup create")
	return CRequestClanLevelup:new()
end
function CRequestClanLevelup:new()
	local self = {}
	setmetatable(self, CRequestClanLevelup)
	self.type = self.PROTOCOL_TYPE
	self.id = 0

	return self
end
function CRequestClanLevelup:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestClanLevelup:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function CRequestClanLevelup:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CRequestClanLevelup
