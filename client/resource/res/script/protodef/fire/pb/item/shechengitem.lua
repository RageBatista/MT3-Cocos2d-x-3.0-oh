require "utils.tableutil"
SHeChengItem = {}
SHeChengItem.__index = SHeChengItem



SHeChengItem.PROTOCOL_TYPE = 787690

function SHeChengItem.Create()
	print("enter SHeChengItem create")
	return SHeChengItem:new()
end
function SHeChengItem:new()
	local self = {}
	setmetatable(self, SHeChengItem)
	self.type = self.PROTOCOL_TYPE
	self.itemnum = 0
	self.getitemid = 0

	return self
end
function SHeChengItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHeChengItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemnum)
	_os_:marshal_int32(self.getitemid)
	return _os_
end

function SHeChengItem:unmarshal(_os_)
	self.itemnum = _os_:unmarshal_int32()
	self.getitemid = _os_:unmarshal_int32()
	return _os_
end

return SHeChengItem
