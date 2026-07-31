require "utils.tableutil"
CSendImpExamAnswer = {}
CSendImpExamAnswer.__index = CSendImpExamAnswer



CSendImpExamAnswer.PROTOCOL_TYPE = 795464

function CSendImpExamAnswer.Create()
	print("enter CSendImpExamAnswer create")
	return CSendImpExamAnswer:new()
end
function CSendImpExamAnswer:new()
	local self = {}
	setmetatable(self, CSendImpExamAnswer)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0
	self.answerid = 0
	self.assisttype = 0

	return self
end
function CSendImpExamAnswer:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendImpExamAnswer:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.impexamtype)
	_os_:marshal_int32(self.answerid)
	_os_:marshal_char(self.assisttype)
	return _os_
end

function CSendImpExamAnswer:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_char()
	self.answerid = _os_:unmarshal_int32()
	self.assisttype = _os_:unmarshal_char()
	return _os_
end

return CSendImpExamAnswer
