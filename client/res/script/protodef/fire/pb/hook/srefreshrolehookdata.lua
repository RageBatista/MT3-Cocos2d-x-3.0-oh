require "utils.tableutil"
require "protodef.rpcgen.fire.pb.hook.hookdata"
SRefreshRoleHookData = {}
SRefreshRoleHookData.__index = SRefreshRoleHookData



SRefreshRoleHookData.PROTOCOL_TYPE = 810333

function SRefreshRoleHookData.Create()
	print("enter SRefreshRoleHookData create")
	return SRefreshRoleHookData:new()
end
function SRefreshRoleHookData:new()
	local self = {}
	setmetatable(self, SRefreshRoleHookData)
	self.type = self.PROTOCOL_TYPE
	self.rolehookdata = HookData:new()

	return self
end
function SRefreshRoleHookData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleHookData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.rolehookdata:marshal(_os_) 
	return _os_
end

function SRefreshRoleHookData:unmarshal(_os_)
	----------------unmarshal bean

	self.rolehookdata:unmarshal(_os_)

	return _os_
end

return SRefreshRoleHookData
