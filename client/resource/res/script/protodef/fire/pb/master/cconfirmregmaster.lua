require "utils.tableutil"
CConfirmRegMaster = {}
CConfirmRegMaster.__index = CConfirmRegMaster



CConfirmRegMaster.PROTOCOL_TYPE = 816445

function CConfirmRegMaster.Create()
	print("enter CConfirmRegMaster create")
	return CConfirmRegMaster:new()
end
function CConfirmRegMaster:new()
	local self = {}
	setmetatable(self, CConfirmRegMaster)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CConfirmRegMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CConfirmRegMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CConfirmRegMaster:unmarshal(_os_)
	return _os_
end

return CConfirmRegMaster
