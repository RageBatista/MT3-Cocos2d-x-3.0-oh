require "utils.tableutil"
SRefreshPetExp = {}
SRefreshPetExp.__index = SRefreshPetExp



SRefreshPetExp.PROTOCOL_TYPE = 788438

function SRefreshPetExp.Create()
	print("enter SRefreshPetExp create")
	return SRefreshPetExp:new()
end
function SRefreshPetExp:new()
	local self = {}
	setmetatable(self, SRefreshPetExp)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.curexp = 0

	return self
end
function SRefreshPetExp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetExp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int64(self.curexp)
	return _os_
end

function SRefreshPetExp:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.curexp = _os_:unmarshal_int64()
	return _os_
end

return SRefreshPetExp
