require "utils.tableutil"
CQueryImpExamState = {}
CQueryImpExamState.__index = CQueryImpExamState



CQueryImpExamState.PROTOCOL_TYPE = 795469

function CQueryImpExamState.Create()
	print("enter CQueryImpExamState create")
	return CQueryImpExamState:new()
end
function CQueryImpExamState:new()
	local self = {}
	setmetatable(self, CQueryImpExamState)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQueryImpExamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryImpExamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQueryImpExamState:unmarshal(_os_)
	return _os_
end

return CQueryImpExamState
