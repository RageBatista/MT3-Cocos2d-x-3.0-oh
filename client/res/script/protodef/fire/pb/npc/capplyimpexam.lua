require "utils.tableutil"
CApplyImpExam = {}
CApplyImpExam.__index = CApplyImpExam



CApplyImpExam.PROTOCOL_TYPE = 795460

function CApplyImpExam.Create()
	print("enter CApplyImpExam create")
	return CApplyImpExam:new()
end
function CApplyImpExam:new()
	local self = {}
	setmetatable(self, CApplyImpExam)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0
	self.operate = 0

	return self
end
function CApplyImpExam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CApplyImpExam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.impexamtype)
	_os_:marshal_char(self.operate)
	return _os_
end

function CApplyImpExam:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_char()
	self.operate = _os_:unmarshal_char()
	return _os_
end

return CApplyImpExam
