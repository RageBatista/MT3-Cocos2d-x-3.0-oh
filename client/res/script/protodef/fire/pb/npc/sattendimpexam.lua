require "utils.tableutil"
SAttendImpExam = {}
SAttendImpExam.__index = SAttendImpExam



SAttendImpExam.PROTOCOL_TYPE = 795458

function SAttendImpExam.Create()
	print("enter SAttendImpExam create")
	return SAttendImpExam:new()
end
function SAttendImpExam:new()
	local self = {}
	setmetatable(self, SAttendImpExam)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0

	return self
end
function SAttendImpExam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAttendImpExam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.impexamtype)
	return _os_
end

function SAttendImpExam:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_int32()
	return _os_
end

return SAttendImpExam
