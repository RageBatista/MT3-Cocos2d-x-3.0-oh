require "utils.tableutil"
CChangeGem = {}
CChangeGem.__index = CChangeGem



CChangeGem.PROTOCOL_TYPE = 810491

function CChangeGem.Create()
	print("enter CChangeGem create")
	return CChangeGem:new()
end
function CChangeGem:new()
	local self = {}
	setmetatable(self, CChangeGem)
	self.type = self.PROTOCOL_TYPE
	self.gemkey = 0
	self.newgemitemid = 0

	return self
end
function CChangeGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.gemkey)
	_os_:marshal_int32(self.newgemitemid)
	return _os_
end

function CChangeGem:unmarshal(_os_)
	self.gemkey = _os_:unmarshal_int32()
	self.newgemitemid = _os_:unmarshal_int32()
	return _os_
end

return CChangeGem
