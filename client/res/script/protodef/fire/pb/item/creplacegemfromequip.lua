require "utils.tableutil"
CReplaceGemFromEquip = {}
CReplaceGemFromEquip.__index = CReplaceGemFromEquip



CReplaceGemFromEquip.PROTOCOL_TYPE = 787759

function CReplaceGemFromEquip.Create()
	print("enter CReplaceGemFromEquip create")
	return CReplaceGemFromEquip:new()
end
function CReplaceGemFromEquip:new()
	local self = {}
	setmetatable(self, CReplaceGemFromEquip)
	self.type = self.PROTOCOL_TYPE
	self.equipitemkey = 0
	self.equipbag = 0
	self.gemindex = 0
	self.gemitemkey = 0

	return self
end
function CReplaceGemFromEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReplaceGemFromEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.equipitemkey)
	_os_:marshal_char(self.equipbag)
	_os_:marshal_int32(self.gemindex)
	_os_:marshal_int32(self.gemitemkey)
	return _os_
end

function CReplaceGemFromEquip:unmarshal(_os_)
	self.equipitemkey = _os_:unmarshal_int32()
	self.equipbag = _os_:unmarshal_char()
	self.gemindex = _os_:unmarshal_int32()
	self.gemitemkey = _os_:unmarshal_int32()
	return _os_
end

return CReplaceGemFromEquip
