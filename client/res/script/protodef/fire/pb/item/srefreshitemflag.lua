require "utils.tableutil"
SRefreshItemFlag = {}
SRefreshItemFlag.__index = SRefreshItemFlag



SRefreshItemFlag.PROTOCOL_TYPE = 787437

function SRefreshItemFlag.Create()
	print("enter SRefreshItemFlag create")
	return SRefreshItemFlag:new()
end
function SRefreshItemFlag:new()
	local self = {}
	setmetatable(self, SRefreshItemFlag)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0
	self.flag = 0
	self.packid = 0

	return self
end
function SRefreshItemFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshItemFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.flag)
	_os_:marshal_int32(self.packid)
	return _os_
end

function SRefreshItemFlag:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_int32()
	return _os_
end

return SRefreshItemFlag
