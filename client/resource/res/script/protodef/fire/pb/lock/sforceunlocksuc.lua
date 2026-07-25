require "utils.tableutil"
SForceUnlockSuc = {}
SForceUnlockSuc.__index = SForceUnlockSuc



SForceUnlockSuc.PROTOCOL_TYPE = 818944

function SForceUnlockSuc.Create()
	print("enter SForceUnlockSuc create")
	return SForceUnlockSuc:new()
end
function SForceUnlockSuc:new()
	local self = {}
	setmetatable(self, SForceUnlockSuc)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SForceUnlockSuc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SForceUnlockSuc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SForceUnlockSuc:unmarshal(_os_)
	return _os_
end

return SForceUnlockSuc
