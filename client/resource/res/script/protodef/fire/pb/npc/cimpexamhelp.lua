require "utils.tableutil"
CImpExamHelp = {}
CImpExamHelp.__index = CImpExamHelp



CImpExamHelp.PROTOCOL_TYPE = 795467

function CImpExamHelp.Create()
	print("enter CImpExamHelp create")
	return CImpExamHelp:new()
end
function CImpExamHelp:new()
	local self = {}
	setmetatable(self, CImpExamHelp)
	self.type = self.PROTOCOL_TYPE
	self.impexamtype = 0

	return self
end
function CImpExamHelp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CImpExamHelp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.impexamtype)
	return _os_
end

function CImpExamHelp:unmarshal(_os_)
	self.impexamtype = _os_:unmarshal_char()
	return _os_
end

return CImpExamHelp
