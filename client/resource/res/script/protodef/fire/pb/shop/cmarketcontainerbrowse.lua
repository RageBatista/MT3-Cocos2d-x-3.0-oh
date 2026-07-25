require "utils.tableutil"
CMarketContainerBrowse = {}
CMarketContainerBrowse.__index = CMarketContainerBrowse



CMarketContainerBrowse.PROTOCOL_TYPE = 810647

function CMarketContainerBrowse.Create()
	print("enter CMarketContainerBrowse create")
	return CMarketContainerBrowse:new()
end
function CMarketContainerBrowse:new()
	local self = {}
	setmetatable(self, CMarketContainerBrowse)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CMarketContainerBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketContainerBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CMarketContainerBrowse:unmarshal(_os_)
	return _os_
end

return CMarketContainerBrowse
