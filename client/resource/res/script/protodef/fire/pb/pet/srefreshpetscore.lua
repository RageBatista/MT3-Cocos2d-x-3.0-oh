require "utils.tableutil"
SRefreshPetScore = {}
SRefreshPetScore.__index = SRefreshPetScore



SRefreshPetScore.PROTOCOL_TYPE = 788511

function SRefreshPetScore.Create()
	print("enter SRefreshPetScore create")
	return SRefreshPetScore:new()
end
function SRefreshPetScore:new()
	local self = {}
	setmetatable(self, SRefreshPetScore)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.petscore = 0
	self.petbasescore = 0

	return self
end
function SRefreshPetScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.petscore)
	_os_:marshal_int32(self.petbasescore)
	return _os_
end

function SRefreshPetScore:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.petscore = _os_:unmarshal_int32()
	self.petbasescore = _os_:unmarshal_int32()
	return _os_
end

return SRefreshPetScore
