require "utils.tableutil"
SSendAlreadyUseItem = {}
SSendAlreadyUseItem.__index = SSendAlreadyUseItem



SSendAlreadyUseItem.PROTOCOL_TYPE = 793458

function SSendAlreadyUseItem.Create()
	print("enter SSendAlreadyUseItem create")
	return SSendAlreadyUseItem:new()
end
function SSendAlreadyUseItem:new()
	local self = {}
	setmetatable(self, SSendAlreadyUseItem)
	self.type = self.PROTOCOL_TYPE
	self.itemlist = {}

	return self
end
function SSendAlreadyUseItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendAlreadyUseItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.itemlist))
	for k,v in pairs(self.itemlist) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SSendAlreadyUseItem:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_itemlist=0,_os_null_itemlist
	_os_null_itemlist, sizeof_itemlist = _os_: uncompact_uint32(sizeof_itemlist)
	for k = 1,sizeof_itemlist do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.itemlist[newkey] = newvalue
	end
	return _os_
end

return SSendAlreadyUseItem
