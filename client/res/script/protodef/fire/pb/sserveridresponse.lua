require "utils.tableutil"
SServerIDResponse = {}
SServerIDResponse.__index = SServerIDResponse



SServerIDResponse.PROTOCOL_TYPE = 786529

function SServerIDResponse.Create()
	print("enter SServerIDResponse create")
	return SServerIDResponse:new()
end
function SServerIDResponse:new()
	local self = {}
	setmetatable(self, SServerIDResponse)
	self.type = self.PROTOCOL_TYPE
	self.serverid = 0

	return self
end
function SServerIDResponse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SServerIDResponse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.serverid)
	return _os_
end

function SServerIDResponse:unmarshal(_os_)
	self.serverid = _os_:unmarshal_int32()
	return _os_
end

return SServerIDResponse
