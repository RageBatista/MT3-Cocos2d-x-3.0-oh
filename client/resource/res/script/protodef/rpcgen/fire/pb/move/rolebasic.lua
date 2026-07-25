require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
RoleBasic = {}
RoleBasic.__index = RoleBasic


function RoleBasic:new()
	local self = {}
	setmetatable(self, RoleBasic)
	self.rolebasicoctets = FireNet.Octets() 
	self.pos = Pos:new()
	self.posz = 0
	self.poses = {}

	return self
end
function RoleBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_: marshal_octets(self.rolebasicoctets)
	----------------marshal bean
	self.pos:marshal(_os_) 
	_os_:marshal_char(self.posz)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.poses))
	for k,v in ipairs(self.poses) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function RoleBasic:unmarshal(_os_)
	_os_:unmarshal_octets(self.rolebasicoctets)
	----------------unmarshal bean

	self.pos:unmarshal(_os_)

	self.posz = _os_:unmarshal_char()
	----------------unmarshal list
	local sizeof_poses=0 ,_os_null_poses
	_os_null_poses, sizeof_poses = _os_: uncompact_uint32(sizeof_poses)
	for k = 1,sizeof_poses do
		----------------unmarshal bean
		self.poses[k]=Pos:new()

		self.poses[k]:unmarshal(_os_)

	end
	return _os_
end

return RoleBasic
