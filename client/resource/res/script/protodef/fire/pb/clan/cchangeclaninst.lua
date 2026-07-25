require "utils.tableutil"
CChangeClanInst = {}
CChangeClanInst.__index = CChangeClanInst



CChangeClanInst.PROTOCOL_TYPE = 808524

function CChangeClanInst.Create()
	print("enter CChangeClanInst create")
	return CChangeClanInst:new()
end
function CChangeClanInst:new()
	local self = {}
	setmetatable(self, CChangeClanInst)
	self.type = self.PROTOCOL_TYPE
	self.claninstservice = 0

	return self
end
function CChangeClanInst:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeClanInst:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.claninstservice)
	return _os_
end

function CChangeClanInst:unmarshal(_os_)
	self.claninstservice = _os_:unmarshal_int32()
	return _os_
end

return CChangeClanInst
