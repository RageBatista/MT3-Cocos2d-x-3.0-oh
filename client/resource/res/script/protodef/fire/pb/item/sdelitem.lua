require "utils.tableutil"
SDelItem = {}
SDelItem.__index = SDelItem



SDelItem.PROTOCOL_TYPE = 787435

function SDelItem.Create()
	print("enter SDelItem create")
	return SDelItem:new()
end
function SDelItem:new()
	local self = {}
	setmetatable(self, SDelItem)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.itemkey = 0

	return self
end
function SDelItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDelItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function SDelItem:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return SDelItem
