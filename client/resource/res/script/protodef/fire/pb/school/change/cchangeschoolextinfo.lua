require "utils.tableutil"
CChangeSchoolExtInfo = {}
CChangeSchoolExtInfo.__index = CChangeSchoolExtInfo



CChangeSchoolExtInfo.PROTOCOL_TYPE = 810487

function CChangeSchoolExtInfo.Create()
	print("enter CChangeSchoolExtInfo create")
	return CChangeSchoolExtInfo:new()
end
function CChangeSchoolExtInfo:new()
	local self = {}
	setmetatable(self, CChangeSchoolExtInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CChangeSchoolExtInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeSchoolExtInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CChangeSchoolExtInfo:unmarshal(_os_)
	return _os_
end

return CChangeSchoolExtInfo
