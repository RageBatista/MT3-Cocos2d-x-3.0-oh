require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.itemrecoverinfobean"
SItemRecoverList = {}
SItemRecoverList.__index = SItemRecoverList



SItemRecoverList.PROTOCOL_TYPE = 787794

function SItemRecoverList.Create()
	print("enter SItemRecoverList create")
	return SItemRecoverList:new()
end
function SItemRecoverList:new()
	local self = {}
	setmetatable(self, SItemRecoverList)
	self.type = self.PROTOCOL_TYPE
	self.items = {}

	return self
end
function SItemRecoverList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemRecoverList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.items))
	for k,v in ipairs(self.items) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SItemRecoverList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_items=0 ,_os_null_items
	_os_null_items, sizeof_items = _os_: uncompact_uint32(sizeof_items)
	for k = 1,sizeof_items do
		----------------unmarshal bean
		self.items[k]=ItemRecoverInfoBean:new()

		self.items[k]:unmarshal(_os_)

	end
	return _os_
end

return SItemRecoverList
