require "utils.tableutil"
require "protodef.rpcgen.fire.pb.pingbi.blackroleinfo"
SBlackRoles = {}
SBlackRoles.__index = SBlackRoles



SBlackRoles.PROTOCOL_TYPE = 819144

function SBlackRoles.Create()
	print("enter SBlackRoles create")
	return SBlackRoles:new()
end
function SBlackRoles:new()
	local self = {}
	setmetatable(self, SBlackRoles)
	self.type = self.PROTOCOL_TYPE
	self.blackroles = {}

	return self
end
function SBlackRoles:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBlackRoles:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.blackroles))
	for k,v in ipairs(self.blackroles) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SBlackRoles:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_blackroles=0,_os_null_blackroles
	_os_null_blackroles, sizeof_blackroles = _os_: uncompact_uint32(sizeof_blackroles)
	for k = 1,sizeof_blackroles do
		----------------unmarshal bean
		self.blackroles[k]=BlackRoleInfo:new()

		self.blackroles[k]:unmarshal(_os_)

	end
	return _os_
end

return SBlackRoles
