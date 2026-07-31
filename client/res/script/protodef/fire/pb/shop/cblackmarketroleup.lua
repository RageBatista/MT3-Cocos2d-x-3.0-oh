require "utils.tableutil"
CBlackMarketRoleUp = {}
CBlackMarketRoleUp.__index = CBlackMarketRoleUp



CBlackMarketRoleUp.PROTOCOL_TYPE = 800314

function CBlackMarketRoleUp.Create()
	print("enter CBlackMarketRoleUp create")
	return CBlackMarketRoleUp:new()
end
function CBlackMarketRoleUp:new()
	local self = {}
	setmetatable(self, CBlackMarketRoleUp)
	self.type = self.PROTOCOL_TYPE
    self.buyrole = 0
    self.price = 0
    self.time = 0
    self.alipay = ""
    self.wechat = ""
	return self
end
function CBlackMarketRoleUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketRoleUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.buyrole)
    _os_:marshal_int32(self.price)
 	_os_:marshal_int32(self.time)
    _os_:marshal_wstring(self.alipay)
    _os_:marshal_wstring(self.wechat)
	return _os_
end

function CBlackMarketRoleUp:unmarshal(_os_)
	self.buyrole = _os_:unmarshal_int64()
	self.price = _os_:unmarshal_int32()
	self.time = _os_:unmarshal_int32()
    self.alipay = _os_:unmarshal_wstring(self.alipay)
    self.wechat = _os_:unmarshal_wstring(self.wechat)
	return _os_
end

return CBlackMarketRoleUp
