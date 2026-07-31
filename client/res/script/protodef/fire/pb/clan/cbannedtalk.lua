require "utils.tableutil"
CBannedtalk = {}
CBannedtalk.__index = CBannedtalk



CBannedtalk.PROTOCOL_TYPE = 808489

function CBannedtalk.Create()
	print("enter CBannedtalk create")
	return CBannedtalk:new()
end
function CBannedtalk:new()
	local self = {}
	setmetatable(self, CBannedtalk)
	self.type = self.PROTOCOL_TYPE
	self.memberid = 0
	self.flag = 0

	return self
end
function CBannedtalk:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBannedtalk:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberid)
	_os_:marshal_int32(self.flag)
	return _os_
end

function CBannedtalk:unmarshal(_os_)
	self.memberid = _os_:unmarshal_int64()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return CBannedtalk
