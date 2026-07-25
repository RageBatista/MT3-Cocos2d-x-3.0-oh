require "utils.tableutil"
SClanInvitation = {}
SClanInvitation.__index = SClanInvitation



SClanInvitation.PROTOCOL_TYPE = 808462

function SClanInvitation.Create()
	print("enter SClanInvitation create")
	return SClanInvitation:new()
end
function SClanInvitation:new()
	local self = {}
	setmetatable(self, SClanInvitation)
	self.type = self.PROTOCOL_TYPE
	self.hostroleid = 0
	self.hostrolename = "" 
	self.clanlevel = 0
	self.clannname = "" 
	self.invitetype = 0

	return self
end
function SClanInvitation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanInvitation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.hostroleid)
	_os_:marshal_wstring(self.hostrolename)
	_os_:marshal_int32(self.clanlevel)
	_os_:marshal_wstring(self.clannname)
	_os_:marshal_char(self.invitetype)
	return _os_
end

function SClanInvitation:unmarshal(_os_)
	self.hostroleid = _os_:unmarshal_int64()
	self.hostrolename = _os_:unmarshal_wstring(self.hostrolename)
	self.clanlevel = _os_:unmarshal_int32()
	self.clannname = _os_:unmarshal_wstring(self.clannname)
	self.invitetype = _os_:unmarshal_char()
	return _os_
end

return SClanInvitation
