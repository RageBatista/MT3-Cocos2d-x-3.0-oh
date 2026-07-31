require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.livedie.ldroleinfodes"
LDRoleInfoWatchDes = {}
LDRoleInfoWatchDes.__index = LDRoleInfoWatchDes


function LDRoleInfoWatchDes:new()
	local self = {}
	setmetatable(self, LDRoleInfoWatchDes)
	self.role1 = LDRoleInfoDes:new()
	self.role2 = LDRoleInfoDes:new()

	return self
end
function LDRoleInfoWatchDes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.role1:marshal(_os_) 
	----------------marshal bean
	self.role2:marshal(_os_) 
	return _os_
end

function LDRoleInfoWatchDes:unmarshal(_os_)
	----------------unmarshal bean

	self.role1:unmarshal(_os_)

	----------------unmarshal bean

	self.role2:unmarshal(_os_)

	return _os_
end

return LDRoleInfoWatchDes
