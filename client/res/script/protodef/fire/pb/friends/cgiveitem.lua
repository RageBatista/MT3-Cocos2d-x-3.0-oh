require "utils.tableutil"
CGiveItem = {}
CGiveItem.__index = CGiveItem



CGiveItem.PROTOCOL_TYPE = 806635

function CGiveItem.Create()
	print("enter CGiveItem create")
	return CGiveItem:new()
end
function CGiveItem:new()
	local self = {}
	setmetatable(self, CGiveItem)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.itemmap = {}

	return self
end
function CGiveItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGiveItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.itemmap))
	for k,v in pairs(self.itemmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function CGiveItem:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_itemmap=0,_os_null_itemmap
	_os_null_itemmap, sizeof_itemmap = _os_: uncompact_uint32(sizeof_itemmap)
	for k = 1,sizeof_itemmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.itemmap[newkey] = newvalue
	end
	return _os_
end

return CGiveItem
