require "utils.tableutil"
CForceUnlockTimeExpire = {}
CForceUnlockTimeExpire.__index = CForceUnlockTimeExpire



CForceUnlockTimeExpire.PROTOCOL_TYPE = 786586

function CForceUnlockTimeExpire.Create()
	print("enter CForceUnlockTimeExpire create")
	return CForceUnlockTimeExpire:new()
end
function CForceUnlockTimeExpire:new()
	local self = {}
	setmetatable(self, CForceUnlockTimeExpire)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CForceUnlockTimeExpire:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CForceUnlockTimeExpire:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CForceUnlockTimeExpire:unmarshal(_os_)
	return _os_
end

return CForceUnlockTimeExpire
