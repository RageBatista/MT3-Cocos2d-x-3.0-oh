require "utils.tableutil"
CEnterDangerConfirm = {}
CEnterDangerConfirm.__index = CEnterDangerConfirm



CEnterDangerConfirm.PROTOCOL_TYPE = 790468

function CEnterDangerConfirm.Create()
	print("enter CEnterDangerConfirm create")
	return CEnterDangerConfirm:new()
end
function CEnterDangerConfirm:new()
	local self = {}
	setmetatable(self, CEnterDangerConfirm)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CEnterDangerConfirm:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEnterDangerConfirm:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CEnterDangerConfirm:unmarshal(_os_)
	return _os_
end

return CEnterDangerConfirm
