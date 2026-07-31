require "utils.tableutil"
SRolePlayAction = {}
SRolePlayAction.__index = SRolePlayAction



SRolePlayAction.PROTOCOL_TYPE = 790488

function SRolePlayAction.Create()
	print("enter SRolePlayAction create")
	return SRolePlayAction:new()
end
function SRolePlayAction:new()
	local self = {}
	setmetatable(self, SRolePlayAction)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.actionid = 0

	return self
end
function SRolePlayAction:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRolePlayAction:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.actionid)
	return _os_
end

function SRolePlayAction:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.actionid = _os_:unmarshal_char()
	return _os_
end

return SRolePlayAction
