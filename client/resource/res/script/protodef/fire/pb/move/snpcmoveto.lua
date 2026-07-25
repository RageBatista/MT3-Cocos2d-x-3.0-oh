require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SNPCMoveTo = {}
SNPCMoveTo.__index = SNPCMoveTo



SNPCMoveTo.PROTOCOL_TYPE = 790482

function SNPCMoveTo.Create()
	print("enter SNPCMoveTo create")
	return SNPCMoveTo:new()
end
function SNPCMoveTo:new()
	local self = {}
	setmetatable(self, SNPCMoveTo)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.speed = 0
	self.destpos = Pos:new()

	return self
end
function SNPCMoveTo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNPCMoveTo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.speed)
	----------------marshal bean
	self.destpos:marshal(_os_) 
	return _os_
end

function SNPCMoveTo:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.speed = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	return _os_
end

return SNPCMoveTo
