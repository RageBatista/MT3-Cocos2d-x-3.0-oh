require "utils.tableutil"
SUpdateRoleSceneState = {}
SUpdateRoleSceneState.__index = SUpdateRoleSceneState



SUpdateRoleSceneState.PROTOCOL_TYPE = 790471

function SUpdateRoleSceneState.Create()
	print("enter SUpdateRoleSceneState create")
	return SUpdateRoleSceneState:new()
end
function SUpdateRoleSceneState:new()
	local self = {}
	setmetatable(self, SUpdateRoleSceneState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.scenestate = 0

	return self
end
function SUpdateRoleSceneState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateRoleSceneState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.scenestate)
	return _os_
end

function SUpdateRoleSceneState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.scenestate = _os_:unmarshal_int32()
	return _os_
end

return SUpdateRoleSceneState
