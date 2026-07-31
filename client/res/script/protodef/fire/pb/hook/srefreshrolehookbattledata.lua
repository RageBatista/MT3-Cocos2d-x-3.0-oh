require "utils.tableutil"
require "protodef.rpcgen.fire.pb.hook.hookbattledata"
SRefreshRoleHookBattleData = {}
SRefreshRoleHookBattleData.__index = SRefreshRoleHookBattleData



SRefreshRoleHookBattleData.PROTOCOL_TYPE = 810339

function SRefreshRoleHookBattleData.Create()
	print("enter SRefreshRoleHookBattleData create")
	return SRefreshRoleHookBattleData:new()
end
function SRefreshRoleHookBattleData:new()
	local self = {}
	setmetatable(self, SRefreshRoleHookBattleData)
	self.type = self.PROTOCOL_TYPE
	self.rolehookbattledata = HookBattleData:new()

	return self
end
function SRefreshRoleHookBattleData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleHookBattleData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.rolehookbattledata:marshal(_os_) 
	return _os_
end

function SRefreshRoleHookBattleData:unmarshal(_os_)
	----------------unmarshal bean

	self.rolehookbattledata:unmarshal(_os_)

	return _os_
end

return SRefreshRoleHookBattleData
