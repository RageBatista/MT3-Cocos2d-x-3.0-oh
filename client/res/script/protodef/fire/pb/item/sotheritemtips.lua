require "utils.tableutil"
SOtherItemTips = {}
SOtherItemTips.__index = SOtherItemTips



SOtherItemTips.PROTOCOL_TYPE = 787768

function SOtherItemTips.Create()
	print("enter SOtherItemTips create")
	return SOtherItemTips:new()
end
function SOtherItemTips:new()
	local self = {}
	setmetatable(self, SOtherItemTips)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.packid = 0
	self.keyinpack = 0
	self.tips = FireNet.Octets() 

	return self
end
function SOtherItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOtherItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_: marshal_octets(self.tips)
	return _os_
end

function SOtherItemTips:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	_os_:unmarshal_octets(self.tips)
	return _os_
end

return SOtherItemTips
