require "utils.tableutil"
SSendRoundPlayEnd = {}
SSendRoundPlayEnd.__index = SSendRoundPlayEnd



SSendRoundPlayEnd.PROTOCOL_TYPE = 793462

function SSendRoundPlayEnd.Create()
	print("enter SSendRoundPlayEnd create")
	return SSendRoundPlayEnd:new()
end
function SSendRoundPlayEnd:new()
	local self = {}
	setmetatable(self, SSendRoundPlayEnd)
	self.type = self.PROTOCOL_TYPE
	self.fighterid = 0

	return self
end
function SSendRoundPlayEnd:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRoundPlayEnd:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.fighterid)
	return _os_
end

function SSendRoundPlayEnd:unmarshal(_os_)
	self.fighterid = _os_:unmarshal_int32()
	return _os_
end

return SSendRoundPlayEnd
