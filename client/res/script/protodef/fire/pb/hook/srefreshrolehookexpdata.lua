require "utils.tableutil"
require "protodef.rpcgen.fire.pb.hook.hookexpdata"
SRefreshRoleHookExpData = {}
SRefreshRoleHookExpData.__index = SRefreshRoleHookExpData



SRefreshRoleHookExpData.PROTOCOL_TYPE = 810340

function SRefreshRoleHookExpData.Create()
	print("enter SRefreshRoleHookExpData create")
	return SRefreshRoleHookExpData:new()
end
function SRefreshRoleHookExpData:new()
	local self = {}
	setmetatable(self, SRefreshRoleHookExpData)
	self.type = self.PROTOCOL_TYPE
	self.rolehookexpdata = HookExpData:new()

	return self
end
function SRefreshRoleHookExpData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleHookExpData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.rolehookexpdata:marshal(_os_) 
	return _os_
end

function SRefreshRoleHookExpData:unmarshal(_os_)
	----------------unmarshal bean

	self.rolehookexpdata:unmarshal(_os_)

	return _os_
end

return SRefreshRoleHookExpData
