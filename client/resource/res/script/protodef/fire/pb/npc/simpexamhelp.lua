require "utils.tableutil"
SImpExamHelp = {}
SImpExamHelp.__index = SImpExamHelp



SImpExamHelp.PROTOCOL_TYPE = 795468

function SImpExamHelp.Create()
	print("enter SImpExamHelp create")
	return SImpExamHelp:new()
end
function SImpExamHelp:new()
	local self = {}
	setmetatable(self, SImpExamHelp)
	self.type = self.PROTOCOL_TYPE
	self.helpcnt = 0

	return self
end
function SImpExamHelp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SImpExamHelp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.helpcnt)
	return _os_
end

function SImpExamHelp:unmarshal(_os_)
	self.helpcnt = _os_:unmarshal_char()
	return _os_
end

return SImpExamHelp
