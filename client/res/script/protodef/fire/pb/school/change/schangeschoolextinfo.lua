require "utils.tableutil"
SChangeSchoolExtInfo = {}
SChangeSchoolExtInfo.__index = SChangeSchoolExtInfo



SChangeSchoolExtInfo.PROTOCOL_TYPE = 810488

function SChangeSchoolExtInfo.Create()
	print("enter SChangeSchoolExtInfo create")
	return SChangeSchoolExtInfo:new()
end
function SChangeSchoolExtInfo:new()
	local self = {}
	setmetatable(self, SChangeSchoolExtInfo)
	self.type = self.PROTOCOL_TYPE
	self.remainchangeweaponcount = 0
	self.remainchangegemcount = 0

	return self
end
function SChangeSchoolExtInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeSchoolExtInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.remainchangeweaponcount)
	_os_:marshal_int32(self.remainchangegemcount)
	return _os_
end

function SChangeSchoolExtInfo:unmarshal(_os_)
	self.remainchangeweaponcount = _os_:unmarshal_int32()
	self.remainchangegemcount = _os_:unmarshal_int32()
	return _os_
end

return SChangeSchoolExtInfo
