require "utils.tableutil"
SCancelLockSuc = {}
SCancelLockSuc.__index = SCancelLockSuc



SCancelLockSuc.PROTOCOL_TYPE = 818943

function SCancelLockSuc.Create()
	print("enter SCancelLockSuc create")
	return SCancelLockSuc:new()
end
function SCancelLockSuc:new()
	local self = {}
	setmetatable(self, SCancelLockSuc)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SCancelLockSuc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCancelLockSuc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SCancelLockSuc:unmarshal(_os_)
	return _os_
end

return SCancelLockSuc
