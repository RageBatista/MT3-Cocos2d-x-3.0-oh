require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
SRequestUpdateRoleInfo = {}
SRequestUpdateRoleInfo.__index = SRequestUpdateRoleInfo



SRequestUpdateRoleInfo.PROTOCOL_TYPE = 806534

function SRequestUpdateRoleInfo.Create()
	print("enter SRequestUpdateRoleInfo create")
	return SRequestUpdateRoleInfo:new()
end
function SRequestUpdateRoleInfo:new()
	local self = {}
	setmetatable(self, SRequestUpdateRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.friendinfobean = InfoBean:new()

	return self
end
function SRequestUpdateRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestUpdateRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	return _os_
end

function SRequestUpdateRoleInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	return _os_
end

return SRequestUpdateRoleInfo
