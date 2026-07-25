require "utils.tableutil"
require "protodef.rpcgen.fire.pb.pingbi.searchblackroleinfo"
SSearchBlackRoleInfo = {}
SSearchBlackRoleInfo.__index = SSearchBlackRoleInfo



SSearchBlackRoleInfo.PROTOCOL_TYPE = 819146

function SSearchBlackRoleInfo.Create()
	print("enter SSearchBlackRoleInfo create")
	return SSearchBlackRoleInfo:new()
end
function SSearchBlackRoleInfo:new()
	local self = {}
	setmetatable(self, SSearchBlackRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.searchblackrole = SearchBlackRoleInfo:new()

	return self
end
function SSearchBlackRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSearchBlackRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.searchblackrole:marshal(_os_) 
	return _os_
end

function SSearchBlackRoleInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.searchblackrole:unmarshal(_os_)

	return _os_
end

return SSearchBlackRoleInfo
