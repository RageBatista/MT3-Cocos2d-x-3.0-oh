require "utils.tableutil"
SUpdateMemberMaxHPMP = {}
SUpdateMemberMaxHPMP.__index = SUpdateMemberMaxHPMP



SUpdateMemberMaxHPMP.PROTOCOL_TYPE = 794461

function SUpdateMemberMaxHPMP.Create()
	print("enter SUpdateMemberMaxHPMP create")
	return SUpdateMemberMaxHPMP:new()
end
function SUpdateMemberMaxHPMP:new()
	local self = {}
	setmetatable(self, SUpdateMemberMaxHPMP)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.maxhp = 0
	self.maxmp = 0

	return self
end
function SUpdateMemberMaxHPMP:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateMemberMaxHPMP:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.maxhp)
	_os_:marshal_int32(self.maxmp)
	return _os_
end

function SUpdateMemberMaxHPMP:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.maxhp = _os_:unmarshal_int32()
	self.maxmp = _os_:unmarshal_int32()
	return _os_
end

return SUpdateMemberMaxHPMP
