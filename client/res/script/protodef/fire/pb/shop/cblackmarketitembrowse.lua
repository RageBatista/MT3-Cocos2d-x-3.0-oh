require "utils.tableutil"
CBlackMarketItemBrowse = {}
CBlackMarketItemBrowse.__index = CBlackMarketItemBrowse



CBlackMarketItemBrowse.PROTOCOL_TYPE = 800311

function CBlackMarketItemBrowse.Create()
	print("enter CBlackMarketItemBrowse create")
	return CBlackMarketItemBrowse:new()
end
function CBlackMarketItemBrowse:new()
	local self = {}
	setmetatable(self, CBlackMarketItemBrowse)
	self.type = self.PROTOCOL_TYPE
	self.page=0
	self.itemtype = 0
	self.name = ""
	return self
end
function CBlackMarketItemBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketItemBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.page)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_wstring(self.name)
	return _os_
end

function CBlackMarketItemBrowse:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.page = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	return _os_
end

return CBlackMarketItemBrowse