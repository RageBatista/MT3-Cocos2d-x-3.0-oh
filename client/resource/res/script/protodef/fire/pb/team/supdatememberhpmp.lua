require "utils.tableutil"
SUpdateMemberHPMP = {}
SUpdateMemberHPMP.__index = SUpdateMemberHPMP



SUpdateMemberHPMP.PROTOCOL_TYPE = 794460

function SUpdateMemberHPMP.Create()
	print("enter SUpdateMemberHPMP create")
	return SUpdateMemberHPMP:new()
end
function SUpdateMemberHPMP:new()
	local self = {}
	setmetatable(self, SUpdateMemberHPMP)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.hp = 0
	self.mp = 0

	return self
end
function SUpdateMemberHPMP:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateMemberHPMP:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.hp)
	_os_:marshal_int32(self.mp)
	return _os_
end

function SUpdateMemberHPMP:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.hp = _os_:unmarshal_int32()
	self.mp = _os_:unmarshal_int32()
	return _os_
end

return SUpdateMemberHPMP
