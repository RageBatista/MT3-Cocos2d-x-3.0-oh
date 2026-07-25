require "utils.tableutil"
CRequestGiveMasterPrenticeTips = {}
CRequestGiveMasterPrenticeTips.__index = CRequestGiveMasterPrenticeTips



CRequestGiveMasterPrenticeTips.PROTOCOL_TYPE = 816473

function CRequestGiveMasterPrenticeTips.Create()
	print("enter CRequestGiveMasterPrenticeTips create")
	return CRequestGiveMasterPrenticeTips:new()
end
function CRequestGiveMasterPrenticeTips:new()
	local self = {}
	setmetatable(self, CRequestGiveMasterPrenticeTips)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestGiveMasterPrenticeTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestGiveMasterPrenticeTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestGiveMasterPrenticeTips:unmarshal(_os_)
	return _os_
end

return CRequestGiveMasterPrenticeTips
