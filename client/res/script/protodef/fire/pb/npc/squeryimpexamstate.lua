require "utils.tableutil"
SQueryImpExamState = {}
SQueryImpExamState.__index = SQueryImpExamState



SQueryImpExamState.PROTOCOL_TYPE = 795470

function SQueryImpExamState.Create()
	print("enter SQueryImpExamState create")
	return SQueryImpExamState:new()
end
function SQueryImpExamState:new()
	local self = {}
	setmetatable(self, SQueryImpExamState)
	self.type = self.PROTOCOL_TYPE
	self.isattend = 0

	return self
end
function SQueryImpExamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryImpExamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.isattend)
	return _os_
end

function SQueryImpExamState:unmarshal(_os_)
	self.isattend = _os_:unmarshal_char()
	return _os_
end

return SQueryImpExamState
