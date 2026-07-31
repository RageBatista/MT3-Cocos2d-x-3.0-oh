require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
SUpdateMemberPosition = {}
SUpdateMemberPosition.__index = SUpdateMemberPosition



SUpdateMemberPosition.PROTOCOL_TYPE = 794471

function SUpdateMemberPosition.Create()
	print("enter SUpdateMemberPosition create")
	return SUpdateMemberPosition:new()
end
function SUpdateMemberPosition:new()
	local self = {}
	setmetatable(self, SUpdateMemberPosition)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.position = Pos1:new()
	self.sceneid = 0

	return self
end
function SUpdateMemberPosition:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateMemberPosition:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.position:marshal(_os_) 
	_os_:marshal_int64(self.sceneid)
	return _os_
end

function SUpdateMemberPosition:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.position:unmarshal(_os_)

	self.sceneid = _os_:unmarshal_int64()
	return _os_
end

return SUpdateMemberPosition
