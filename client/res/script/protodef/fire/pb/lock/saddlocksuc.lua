require "utils.tableutil"
SAddLockSuc = {}
SAddLockSuc.__index = SAddLockSuc



SAddLockSuc.PROTOCOL_TYPE = 818941

function SAddLockSuc.Create()
	print("enter SAddLockSuc create")
	return SAddLockSuc:new()
end
function SAddLockSuc:new()
	local self = {}
	setmetatable(self, SAddLockSuc)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SAddLockSuc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddLockSuc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SAddLockSuc:unmarshal(_os_)
	return _os_
end

return SAddLockSuc
