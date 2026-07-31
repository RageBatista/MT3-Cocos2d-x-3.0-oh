require "utils.tableutil"
SChangeClanInst = {}
SChangeClanInst.__index = SChangeClanInst



SChangeClanInst.PROTOCOL_TYPE = 808525

function SChangeClanInst.Create()
	print("enter SChangeClanInst create")
	return SChangeClanInst:new()
end
function SChangeClanInst:new()
	local self = {}
	setmetatable(self, SChangeClanInst)
	self.type = self.PROTOCOL_TYPE
	self.claninstservice = 0

	return self
end
function SChangeClanInst:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeClanInst:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.claninstservice)
	return _os_
end

function SChangeClanInst:unmarshal(_os_)
	self.claninstservice = _os_:unmarshal_int32()
	return _os_
end

return SChangeClanInst
