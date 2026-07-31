require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
NpcBasic = {}
NpcBasic.__index = NpcBasic


function NpcBasic:new()
	local self = {}
	setmetatable(self, NpcBasic)
	self.npckey = 0
	self.id = 0
	self.name = "" 
	self.pos = Pos:new()
	self.posz = 0
	self.destpos = Pos:new()
	self.speed = 0
	self.dir = 0
	self.shape = 0
	self.scenestate = 0
	self.components = {}

	return self
end
function NpcBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.id)
	_os_:marshal_wstring(self.name)
	----------------marshal bean
	self.pos:marshal(_os_) 
	_os_:marshal_char(self.posz)
	----------------marshal bean
	self.destpos:marshal(_os_) 
	_os_:marshal_int32(self.speed)
	_os_:marshal_int32(self.dir)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.scenestate)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function NpcBasic:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.id = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	----------------unmarshal bean

	self.pos:unmarshal(_os_)

	self.posz = _os_:unmarshal_char()
	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	self.speed = _os_:unmarshal_int32()
	self.dir = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.scenestate = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return NpcBasic
