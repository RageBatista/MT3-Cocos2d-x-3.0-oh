require "utils.tableutil"
CConfirmImpExam = {}
CConfirmImpExam.__index = CConfirmImpExam



CConfirmImpExam.PROTOCOL_TYPE = 795459

function CConfirmImpExam.Create()
	print("enter CConfirmImpExam create")
	return CConfirmImpExam:new()
end
function CConfirmImpExam:new()
	local self = {}
	setmetatable(self, CConfirmImpExam)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0
	self.operate = 0

	return self
end
function CConfirmImpExam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CConfirmImpExam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.impexamtype)
	_os_:marshal_char(self.operate)
	return _os_
end

function CConfirmImpExam:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_int32()
	self.operate = _os_:unmarshal_char()
	return _os_
end

return CConfirmImpExam
