require "utils.tableutil"
CRequestAsMaster = {}
CRequestAsMaster.__index = CRequestAsMaster



CRequestAsMaster.PROTOCOL_TYPE = 816458

function CRequestAsMaster.Create()
	print("enter CRequestAsMaster create")
	return CRequestAsMaster:new()
end
function CRequestAsMaster:new()
	local self = {}
	setmetatable(self, CRequestAsMaster)
	self.type = self.PROTOCOL_TYPE
	self.prenticeid = 0

	return self
end
function CRequestAsMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestAsMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prenticeid)
	return _os_
end

function CRequestAsMaster:unmarshal(_os_)
	self.prenticeid = _os_:unmarshal_int64()
	return _os_
end

return CRequestAsMaster
