require "utils.tableutil"
SOutReawardResult = {}
SOutReawardResult.__index = SOutReawardResult



SOutReawardResult.PROTOCOL_TYPE = 817970

function SOutReawardResult.Create()
	print("enter SOutReawardResult create")
	return SOutReawardResult:new()
end
function SOutReawardResult:new()
	local self = {}
	setmetatable(self, SOutReawardResult)
	self.type = self.PROTOCOL_TYPE

	return self
end
function SOutReawardResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOutReawardResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SOutReawardResult:unmarshal(_os_)
	return _os_
end

return SOutReawardResult
