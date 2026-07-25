require "utils.tableutil"
require "protodef.fire.pb.shop.goldorderinfo"
SGoldOrderBrowseIndex = {}
SGoldOrderBrowseIndex.__index = SGoldOrderBrowseIndex

SGoldOrderBrowseIndex.PROTOCOL_TYPE = 800305

function SGoldOrderBrowseIndex.Create()
	print("enter SGoldOrderBrowseIndex create")
	return SGoldOrderBrowseIndex:new()
end
function SGoldOrderBrowseIndex:new()
	local self = {}
	setmetatable(self, SGoldOrderBrowseIndex)
	self.type = self.PROTOCOL_TYPE
	self.goldlist = {}
	self.total=0
    self.hasmore=0
	self.isclear=0

	return self
end
function SGoldOrderBrowseIndex:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGoldOrderBrowseIndex:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goldlist))
	for k,v in ipairs(self.goldlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end
    _os_:marshal_int32(self.total)
    _os_:marshal_int32(self.hasmore)
    _os_:marshal_int32(self.isclear)

	return _os_
end

function SGoldOrderBrowseIndex:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_salelist=0,_os_null_salelist
	_os_null_salelist, sizeof_salelist = _os_: uncompact_uint32(sizeof_salelist)
	for k = 1,sizeof_salelist do
		----------------unmarshal bean
		self.goldlist[k]=GoldOrderInfo:new()

		self.goldlist[k]:unmarshal(_os_)

	end
    self.total = _os_:unmarshal_int32()
    self.hasmore = _os_:unmarshal_int32()
    self.isclear = _os_:unmarshal_int32()
	return _os_
end

return SGoldOrderBrowseIndex
