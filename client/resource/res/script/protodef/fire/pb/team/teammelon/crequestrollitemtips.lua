require "utils.tableutil"
CRequestRollItemTips = {}
CRequestRollItemTips.__index = CRequestRollItemTips



CRequestRollItemTips.PROTOCOL_TYPE = 794525

function CRequestRollItemTips.Create()
	print("enter CRequestRollItemTips create")
	return CRequestRollItemTips:new()
end
function CRequestRollItemTips:new()
	local self = {}
	setmetatable(self, CRequestRollItemTips)
	self.type = self.PROTOCOL_TYPE
	self.melonid = 0

	return self
end
function CRequestRollItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRollItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.melonid)
	return _os_
end

function CRequestRollItemTips:unmarshal(_os_)
	self.melonid = _os_:unmarshal_int64()
	return _os_
end

return CRequestRollItemTips
