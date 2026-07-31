require "utils.tableutil"
SReqUsePetColor = {}
SReqUsePetColor.__index = SReqUsePetColor



SReqUsePetColor.PROTOCOL_TYPE = 786544

function SReqUsePetColor.Create()
	print("enter SReqUsePetColor create")
	return SReqUsePetColor:new()
end
function SReqUsePetColor:new()
	local self = {}
	setmetatable(self, SReqUsePetColor)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.colorpos1 = 0
	self.colorpos2 = 0

	return self
end
function SReqUsePetColor:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqUsePetColor:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.colorpos1)
	_os_:marshal_int32(self.colorpos2)
	return _os_
end

function SReqUsePetColor:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.colorpos1 = _os_:unmarshal_int32()
	self.colorpos2 = _os_:unmarshal_int32()
	return _os_
end

return SReqUsePetColor
