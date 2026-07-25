require "utils.tableutil"
COtherItemTips = {}
COtherItemTips.__index = COtherItemTips



COtherItemTips.PROTOCOL_TYPE = 787767

function COtherItemTips.Create()
	print("enter COtherItemTips create")
	return COtherItemTips:new()
end
function COtherItemTips:new()
	local self = {}
	setmetatable(self, COtherItemTips)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.packid = 0
	self.keyinpack = 0

	return self
end
function COtherItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COtherItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function COtherItemTips:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return COtherItemTips
