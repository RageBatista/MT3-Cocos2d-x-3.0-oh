require "utils.tableutil"

WenShiItem = {}
WenShiItem.__index = WenShiItem


function WenShiItem:new()
	local self = {}
	setmetatable(self, WenShiItem)
	self.id = 0
	self.pos = 0
	self.level = 0
	self.pinzhi = 0
	self.naijiu = 0
	self.shuxing = {}

	return self
end
function WenShiItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.pos)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.pinzhi)
	_os_:marshal_int32(self.naijiu)
	_os_:compact_uint32(TableUtil.tablelength(self.shuxing))
	for k,v in ipairs(self.shuxing) do
		----------------marshal bean
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function WenShiItem:unmarshal(_os_)

	self.id = _os_:unmarshal_int32()
	self.pos = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.pinzhi = _os_:unmarshal_int32()
	self.naijiu = _os_:unmarshal_int32()
	local sizeof_shuxing=0,_os_null_shuxing
	_os_null_shuxing, sizeof_shuxing = _os_: uncompact_uint32(sizeof_shuxing)
	for k = 1,sizeof_shuxing do
		local newkey = _os_:unmarshal_int32()
		local newv = _os_:unmarshal_int32()
		self.shuxing[newkey]=newv
	end
	return _os_
end

return WenShiItem
