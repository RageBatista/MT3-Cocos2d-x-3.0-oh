require "utils.tableutil"
CMarketAttentionBrowse = {}
CMarketAttentionBrowse.__index = CMarketAttentionBrowse



CMarketAttentionBrowse.PROTOCOL_TYPE = 810660

function CMarketAttentionBrowse.Create()
	print("enter CMarketAttentionBrowse create")
	return CMarketAttentionBrowse:new()
end
function CMarketAttentionBrowse:new()
	local self = {}
	setmetatable(self, CMarketAttentionBrowse)
	self.type = self.PROTOCOL_TYPE
	self.attentype = 0

	return self
end
function CMarketAttentionBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketAttentionBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.attentype)
	return _os_
end

function CMarketAttentionBrowse:unmarshal(_os_)
	self.attentype = _os_:unmarshal_int32()
	return _os_
end

return CMarketAttentionBrowse
