require "utils.tableutil"
GNetServerIDResponse = {}
GNetServerIDResponse.__index = GNetServerIDResponse



GNetServerIDResponse.PROTOCOL_TYPE = 8902

function GNetServerIDResponse.Create()
	print("enter GNetServerIDResponse create")
	return GNetServerIDResponse:new()
end
function GNetServerIDResponse:new()
	local self = {}
	setmetatable(self, GNetServerIDResponse)
	self.type = self.PROTOCOL_TYPE
	self.plattype = 0
	self.serverid = FireNet.Octets()

	return self
end
function GNetServerIDResponse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function GNetServerIDResponse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.plattype)
	_os_:marshal_octets(self.serverid)
	return _os_
end

function GNetServerIDResponse:unmarshal(_os_)
	self.plattype = _os_:unmarshal_int32()
	_os_:unmarshal_octets(self.serverid)
	return _os_
end

return GNetServerIDResponse
