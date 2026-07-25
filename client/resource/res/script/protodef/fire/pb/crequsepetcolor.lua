require "utils.tableutil"
CReqUsePetColor = {}
CReqUsePetColor.__index = CReqUsePetColor



CReqUsePetColor.PROTOCOL_TYPE = 786545

function CReqUsePetColor.Create()
	print("enter CReqUsePetColor create")
	return CReqUsePetColor:new()
end
function CReqUsePetColor:new()
	local self = {}
	setmetatable(self, CReqUsePetColor)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.colorpos1 = 0
	self.colorpos2 = 0

	return self
end
function CReqUsePetColor:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqUsePetColor:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.colorpos1)
	_os_:marshal_int32(self.colorpos2)
	return _os_
end

function CReqUsePetColor:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.colorpos1 = _os_:unmarshal_int32()
	self.colorpos2 = _os_:unmarshal_int32()
	return _os_
end

return CReqUsePetColor
