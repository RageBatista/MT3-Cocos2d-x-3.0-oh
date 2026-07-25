require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.invitationroleinfo"
SClanInvitationView = {}
SClanInvitationView.__index = SClanInvitationView



SClanInvitationView.PROTOCOL_TYPE = 808521

function SClanInvitationView.Create()
	print("enter SClanInvitationView create")
	return SClanInvitationView:new()
end
function SClanInvitationView:new()
	local self = {}
	setmetatable(self, SClanInvitationView)
	self.type = self.PROTOCOL_TYPE
	self.invitationroleinfolist = {}

	return self
end
function SClanInvitationView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanInvitationView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.invitationroleinfolist))
	for k,v in ipairs(self.invitationroleinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SClanInvitationView:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_invitationroleinfolist=0,_os_null_invitationroleinfolist
	_os_null_invitationroleinfolist, sizeof_invitationroleinfolist = _os_: uncompact_uint32(sizeof_invitationroleinfolist)
	for k = 1,sizeof_invitationroleinfolist do
		----------------unmarshal bean
		self.invitationroleinfolist[k]=InvitationRoleInfo:new()

		self.invitationroleinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return SClanInvitationView
