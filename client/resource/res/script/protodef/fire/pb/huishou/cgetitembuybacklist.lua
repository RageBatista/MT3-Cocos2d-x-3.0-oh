require "utils.tableutil"
CGetItemBuyBackList = {}
CGetItemBuyBackList.__index = CGetItemBuyBackList



CGetItemBuyBackList.PROTOCOL_TYPE = 819407

function CGetItemBuyBackList.Create()
	print("enter CGetItemBuyBackList create")
	return CGetItemBuyBackList:new()
end
function CGetItemBuyBackList:new()
	local self = {}
	setmetatable(self, CGetItemBuyBackList)
	self.type = self.PROTOCOL_TYPE
	self.findtype = 0
	self.itemtype = 0
	self.istimelimit = 0
	self.page = 0
	self.pagesize = 0

	return self
end
function CGetItemBuyBackList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetItemBuyBackList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.findtype)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.istimelimit)
	_os_:marshal_int32(self.page)
	_os_:marshal_int32(self.pagesize)
	return _os_
end

function CGetItemBuyBackList:unmarshal(_os_)
	self.findtype = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.istimelimit = _os_:unmarshal_int32()
	self.page = _os_:unmarshal_int32()
	self.pagesize = _os_:unmarshal_int32()
	return _os_
end



return CGetItemBuyBackList
