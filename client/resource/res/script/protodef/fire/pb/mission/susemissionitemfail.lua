require "utils.tableutil"
SUseMissionItemFail = {}
SUseMissionItemFail.__index = SUseMissionItemFail



SUseMissionItemFail.PROTOCOL_TYPE = 805459

function SUseMissionItemFail.Create()
	print("enter SUseMissionItemFail create")
	return SUseMissionItemFail:new()
end
function SUseMissionItemFail:new()
	local self = {}
	setmetatable(self, SUseMissionItemFail)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SUseMissionItemFail:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUseMissionItemFail:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SUseMissionItemFail:unmarshal(_os_)
	return _os_
end

return SUseMissionItemFail
