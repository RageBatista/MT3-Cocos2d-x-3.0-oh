require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.itembuybackos"
SItemBuyBackList = {}
SItemBuyBackList.__index = SItemBuyBackList



SItemBuyBackList.PROTOCOL_TYPE = 819408


function SItemBuyBackList.Create()
	print("enter SItemBuyBackList create")
	return SItemBuyBackList:new()
end
function SItemBuyBackList:new()
	local self = {}
	setmetatable(self, SItemBuyBackList)
	self.type = self.PROTOCOL_TYPE
	self.findtype = 0
	self.itemtype = 0
	self.istimelimit = 0
	self.page = 0
	self.pagesize = 0
	self.pagetotal = 0
	self.itembuybackos = {}

	return self
end
function SItemBuyBackList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemBuyBackList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.findtype)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.istimelimit)
	_os_:marshal_int32(self.page)
	_os_:marshal_int32(self.pagesize)
	_os_:marshal_int32(self.pagetotal)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.itembuybackos))
	for k,v in ipairs(self.itembuybackos) do
		----------------marshal bean
		v:marshal(_os_)
	end

	return _os_
end

function SItemBuyBackList:unmarshal(_os_)
	self.findtype = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.istimelimit = _os_:unmarshal_int32()
	self.page = _os_:unmarshal_int32()
	self.pagesize = _os_:unmarshal_int32()
	self.pagetotal = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_itembuybackos=0,_os_null_itembuybackos
	_os_null_itembuybackos, sizeof_itembuybackos = _os_: uncompact_uint32(sizeof_itembuybackos)
	for k = 1,sizeof_itembuybackos do
		----------------unmarshal bean
		self.itembuybackos[k]=ItemBuyBackOs:new()

		self.itembuybackos[k]:unmarshal(_os_)

	end
	return _os_
end

return SItemBuyBackList
