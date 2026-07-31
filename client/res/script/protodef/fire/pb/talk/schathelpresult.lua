require "utils.tableutil"
SChatHelpResult = {}
SChatHelpResult.__index = SChatHelpResult



SChatHelpResult.PROTOCOL_TYPE = 792448

function SChatHelpResult.Create()
	print("enter SChatHelpResult create")
	return SChatHelpResult:new()
end
function SChatHelpResult:new()
	local self = {}
	setmetatable(self, SChatHelpResult)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SChatHelpResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChatHelpResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function SChatHelpResult:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SChatHelpResult
