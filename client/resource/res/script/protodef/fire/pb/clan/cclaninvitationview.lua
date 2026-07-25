require "utils.tableutil"
CClanInvitationView = {}
CClanInvitationView.__index = CClanInvitationView



CClanInvitationView.PROTOCOL_TYPE = 808520

function CClanInvitationView.Create()
	print("enter CClanInvitationView create")
	return CClanInvitationView:new()
end
function CClanInvitationView:new()
	local self = {}
	setmetatable(self, CClanInvitationView)
	self.type = self.PROTOCOL_TYPE
	self.type_level = 0
	self.type_school = 0
	self.type_sex = 0

	return self
end
function CClanInvitationView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClanInvitationView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.type_level)
	_os_:marshal_int32(self.type_school)
	_os_:marshal_int32(self.type_sex)
	return _os_
end

function CClanInvitationView:unmarshal(_os_)
	self.type_level = _os_:unmarshal_int32()
	self.type_school = _os_:unmarshal_int32()
	self.type_sex = _os_:unmarshal_int32()
	return _os_
end

return CClanInvitationView
