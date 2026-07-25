require "utils.tableutil"
SSendImpExamAssist = {}
SSendImpExamAssist.__index = SSendImpExamAssist



SSendImpExamAssist.PROTOCOL_TYPE = 795466

function SSendImpExamAssist.Create()
	print("enter SSendImpExamAssist create")
	return SSendImpExamAssist:new()
end
function SSendImpExamAssist:new()
	local self = {}
	setmetatable(self, SSendImpExamAssist)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0
	self.assisttype = 0
	self.answerid = 0

	return self
end
function SSendImpExamAssist:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendImpExamAssist:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.impexamtype)
	_os_:marshal_char(self.assisttype)
	_os_:marshal_int32(self.answerid)
	return _os_
end

function SSendImpExamAssist:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_char()
	self.assisttype = _os_:unmarshal_char()
	self.answerid = _os_:unmarshal_int32()
	return _os_
end

return SSendImpExamAssist
