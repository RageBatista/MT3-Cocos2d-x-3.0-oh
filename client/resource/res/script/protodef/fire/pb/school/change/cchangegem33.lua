require "utils.tableutil"
CChangeGem33 = {}
CChangeGem33.__index = CChangeGem33



CChangeGem33.PROTOCOL_TYPE = 817933

function CChangeGem33.Create()
	print("enter CChangeGem33 create")
	return CChangeGem33:new()
end
function CChangeGem33:new()
	local self = {}
	setmetatable(self, CChangeGem33)
	self.type = self.PROTOCOL_TYPE
	self.gemkey = 0
	self.newgemitemid = 0

	return self
end
function CChangeGem33:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeGem33:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.gemkey)
	_os_:marshal_int32(self.newgemitemid)
	return _os_
end

function CChangeGem33:unmarshal(_os_)
	self.gemkey = _os_:unmarshal_int32()
	self.newgemitemid = _os_:unmarshal_int32()
	return _os_
end

return CChangeGem33
