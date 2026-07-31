require "utils.tableutil"
CRequestVipInfo = {}
CRequestVipInfo.__index = CRequestVipInfo



CRequestVipInfo.PROTOCOL_TYPE = 812487

function CRequestVipInfo.Create()
	print("enter CRequestVipInfo create")
	return CRequestVipInfo:new()
end
function CRequestVipInfo:new()
	local self = {}
	setmetatable(self, CRequestVipInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestVipInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestVipInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestVipInfo:unmarshal(_os_)
	return _os_
end

return CRequestVipInfo
