require "utils.tableutil"
require "protodef.rpcgen.fire.pb.npc.submitunit"
CSubmit2Npc = {}
CSubmit2Npc.__index = CSubmit2Npc



CSubmit2Npc.PROTOCOL_TYPE = 795456

function CSubmit2Npc.Create()
	print("enter CSubmit2Npc create")
	return CSubmit2Npc:new()
end
function CSubmit2Npc:new()
	local self = {}
	setmetatable(self, CSubmit2Npc)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.npckey = 0
	self.submittype = 0
	self.things = {}

	return self
end
function CSubmit2Npc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSubmit2Npc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.submittype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.things))
	for k,v in ipairs(self.things) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CSubmit2Npc:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.submittype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_things=0,_os_null_things
	_os_null_things, sizeof_things = _os_: uncompact_uint32(sizeof_things)
	for k = 1,sizeof_things do
		----------------unmarshal bean
		self.things[k]=SubmitUnit:new()

		self.things[k]:unmarshal(_os_)

	end
	return _os_
end

return CSubmit2Npc
