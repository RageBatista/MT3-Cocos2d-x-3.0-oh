require "utils.tableutil"
CChangeSchool = {}
CChangeSchool.__index = CChangeSchool



CChangeSchool.PROTOCOL_TYPE = 810485

function CChangeSchool.Create()
	print("enter CChangeSchool create")
	return CChangeSchool:new()
end
function CChangeSchool:new()
	local self = {}
	setmetatable(self, CChangeSchool)
	self.type = self.PROTOCOL_TYPE
	self.newshape = 0
	self.newschool = 0

	return self
end
function CChangeSchool:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeSchool:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.newshape)
	_os_:marshal_int32(self.newschool)
	return _os_
end

function CChangeSchool:unmarshal(_os_)
	self.newshape = _os_:unmarshal_int32()
	self.newschool = _os_:unmarshal_int32()
	return _os_
end

return CChangeSchool
