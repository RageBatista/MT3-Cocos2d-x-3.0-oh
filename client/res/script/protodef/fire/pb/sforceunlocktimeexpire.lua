require "utils.tableutil"
SForceUnlockTimeExpire = {}
SForceUnlockTimeExpire.__index = SForceUnlockTimeExpire



SForceUnlockTimeExpire.PROTOCOL_TYPE = 786587

function SForceUnlockTimeExpire.Create()
	print("enter SForceUnlockTimeExpire create")
	return SForceUnlockTimeExpire:new()
end
function SForceUnlockTimeExpire:new()
	local self = {}
	setmetatable(self, SForceUnlockTimeExpire)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SForceUnlockTimeExpire:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SForceUnlockTimeExpire:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SForceUnlockTimeExpire:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SForceUnlockTimeExpire
