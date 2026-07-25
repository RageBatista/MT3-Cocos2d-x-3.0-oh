require "utils.tableutil"
CEvaluateMasterResult = {}
CEvaluateMasterResult.__index = CEvaluateMasterResult



CEvaluateMasterResult.PROTOCOL_TYPE = 816456

function CEvaluateMasterResult.Create()
	print("enter CEvaluateMasterResult create")
	return CEvaluateMasterResult:new()
end
function CEvaluateMasterResult:new()
	local self = {}
	setmetatable(self, CEvaluateMasterResult)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function CEvaluateMasterResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEvaluateMasterResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function CEvaluateMasterResult:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return CEvaluateMasterResult
