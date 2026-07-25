require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.qcroleinfodes"
QCRoleInfoWatchDes = {}
QCRoleInfoWatchDes.__index = QCRoleInfoWatchDes


function QCRoleInfoWatchDes:new()
	local self = {}
	setmetatable(self, QCRoleInfoWatchDes)
	self.role1 = QCRoleInfoDes:new()
	self.role2 = QCRoleInfoDes:new()

	return self
end
function QCRoleInfoWatchDes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.role1:marshal(_os_) 
	----------------marshal bean
	self.role2:marshal(_os_) 
	return _os_
end

function QCRoleInfoWatchDes:unmarshal(_os_)
	----------------unmarshal bean

	self.role1:unmarshal(_os_)

	----------------unmarshal bean

	self.role2:unmarshal(_os_)

	return _os_
end

return QCRoleInfoWatchDes
