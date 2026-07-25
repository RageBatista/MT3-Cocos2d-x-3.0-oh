require "utils.tableutil"
SSendVipInfo = {
	RIGHT_HUOBAN = 0,
	RIGHT_STORAGE = 1,
	RIGHT_PACKAGE = 2,
	RIGHT_WEEKLY_DISCOUNT_COUNT = 3,
	RIGHT_EXT_YINFURATE = 4,
	RIGHT_DAILY_GOODS_COUNT = 5,
	RIGHT_PET_SLOT = 6,
	RIGHT_SUPPREG_COUNT = 7
}
SSendVipInfo.__index = SSendVipInfo



SSendVipInfo.PROTOCOL_TYPE = 812489

function SSendVipInfo.Create()
	print("enter SSendVipInfo create")
	return SSendVipInfo:new()
end
function SSendVipInfo:new()
	local self = {}
	setmetatable(self, SSendVipInfo)
	self.type = self.PROTOCOL_TYPE
	self.vipexp = 0
	self.viplevel = 0
	self.bounus = 0
	self.gotbounus = 0
	self.viprights = {}

	return self
end
function SSendVipInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendVipInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.vipexp)
	_os_:marshal_int32(self.viplevel)
	_os_:marshal_int32(self.bounus)
	_os_:marshal_int32(self.gotbounus)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.viprights))
	for k,v in ipairs(self.viprights) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SSendVipInfo:unmarshal(_os_)
	self.vipexp = _os_:unmarshal_int32()
	self.viplevel = _os_:unmarshal_int32()
	self.bounus = _os_:unmarshal_int32()
	self.gotbounus = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_viprights=0,_os_null_viprights
	_os_null_viprights, sizeof_viprights = _os_: uncompact_uint32(sizeof_viprights)
	for k = 1,sizeof_viprights do
		self.viprights[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SSendVipInfo
