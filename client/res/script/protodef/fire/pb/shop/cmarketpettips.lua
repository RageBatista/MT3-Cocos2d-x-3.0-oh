require "utils.tableutil"
CMarketPetTips = {}
CMarketPetTips.__index = CMarketPetTips



CMarketPetTips.PROTOCOL_TYPE = 810649

function CMarketPetTips.Create()
	print("enter CMarketPetTips create")
	return CMarketPetTips:new()
end
function CMarketPetTips:new()
	local self = {}
	setmetatable(self, CMarketPetTips)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.key = 0
	self.tipstype = 0

	return self
end
function CMarketPetTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketPetTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.tipstype)
	return _os_
end

function CMarketPetTips:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.key = _os_:unmarshal_int32()
	self.tipstype = _os_:unmarshal_int32()
	return _os_
end

return CMarketPetTips
