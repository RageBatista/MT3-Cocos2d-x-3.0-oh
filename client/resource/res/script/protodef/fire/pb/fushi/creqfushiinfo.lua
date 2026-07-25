require "utils.tableutil"
CReqFushiInfo = {}
CReqFushiInfo.__index = CReqFushiInfo



CReqFushiInfo.PROTOCOL_TYPE = 812490

function CReqFushiInfo.Create()
	print("enter CReqFushiInfo create")
	return CReqFushiInfo:new()
end
function CReqFushiInfo:new()
	local self = {}
	setmetatable(self, CReqFushiInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqFushiInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqFushiInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqFushiInfo:unmarshal(_os_)
	return _os_
end

return CReqFushiInfo
