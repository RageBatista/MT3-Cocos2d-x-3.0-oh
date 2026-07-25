require "utils.tableutil"
CGoldOrderBrowseIndex = {}
CGoldOrderBrowseIndex.__index = CGoldOrderBrowseIndex



CGoldOrderBrowseIndex.PROTOCOL_TYPE = 800303

function CGoldOrderBrowseIndex.Create()
	print("enter CGoldOrderBrowseIndex create")
	return CGoldOrderBrowseIndex:new()
end
function CGoldOrderBrowseIndex:new()
	local self = {}
	setmetatable(self, CGoldOrderBrowseIndex)
	self.type = self.PROTOCOL_TYPE
	self.page=0
	self.minnum = 0
	self.maxnum = 0
	self.minprice = 0
    self.maxprice = 0
	return self
end
function CGoldOrderBrowseIndex:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderBrowseIndex:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.page)
	_os_:marshal_int32(self.minnum)
	_os_:marshal_int32(self.maxnum)
	_os_:marshal_int32(self.minprice)
	_os_:marshal_int32(self.maxprice)
	return _os_
end

function CGoldOrderBrowseIndex:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.page = _os_:unmarshal_int32()
	self.minnum = _os_:unmarshal_int32()
	self.maxnum = _os_:unmarshal_int32()
	self.minprice = _os_:unmarshal_int32()
	self.maxprice = _os_:unmarshal_int32()
	return _os_
end

return CGoldOrderBrowseIndex
