require "utils.tableutil"
CBlackMarketContainerBrowse = {}
CBlackMarketContainerBrowse.__index = CBlackMarketContainerBrowse



CBlackMarketContainerBrowse.PROTOCOL_TYPE = 800308

function CBlackMarketContainerBrowse.Create()
	print("enter CBlackMarketContainerBrowse create")
	return CBlackMarketContainerBrowse:new()
end
function CBlackMarketContainerBrowse:new()
	local self = {}
	setmetatable(self, CBlackMarketContainerBrowse)
	self.type = self.PROTOCOL_TYPE
	self.state = 0

	return self
end
function CBlackMarketContainerBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketContainerBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.state)
	return _os_
end

function CBlackMarketContainerBrowse:unmarshal(_os_)
	self.state = _os_:unmarshal_int32()
	return _os_
end

return CBlackMarketContainerBrowse
