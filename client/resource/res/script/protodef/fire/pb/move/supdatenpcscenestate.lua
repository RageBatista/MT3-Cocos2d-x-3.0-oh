require "utils.tableutil"
SUpdateNpcSceneState = {}
SUpdateNpcSceneState.__index = SUpdateNpcSceneState



SUpdateNpcSceneState.PROTOCOL_TYPE = 790472

function SUpdateNpcSceneState.Create()
	print("enter SUpdateNpcSceneState create")
	return SUpdateNpcSceneState:new()
end
function SUpdateNpcSceneState:new()
	local self = {}
	setmetatable(self, SUpdateNpcSceneState)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.scenestate = 0

	return self
end
function SUpdateNpcSceneState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateNpcSceneState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.scenestate)
	return _os_
end

function SUpdateNpcSceneState:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.scenestate = _os_:unmarshal_int32()
	return _os_
end

return SUpdateNpcSceneState
