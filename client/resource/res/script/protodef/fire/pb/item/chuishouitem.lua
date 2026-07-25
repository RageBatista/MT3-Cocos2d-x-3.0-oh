require "utils.tableutil"
CHuiShouItem = {}
CHuiShouItem.__index = CHuiShouItem



CHuiShouItem.PROTOCOL_TYPE = 800016

function CHuiShouItem.Create()
	print("enter CHuiShouItem create")
	return CHuiShouItem:new()
end
function CHuiShouItem:new()
	local self = {}
	setmetatable(self, CHuiShouItem)
	self.type = self.PROTOCOL_TYPE
	self.huishou = 0
	self.packid = 0
	self.keyinpack = 0

	return self
end
function CHuiShouItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CHuiShouItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huishou)
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function CHuiShouItem:unmarshal(_os_)
	self.huishou = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return CHuiShouItem
