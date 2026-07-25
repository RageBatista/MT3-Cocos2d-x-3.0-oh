require "utils.tableutil"
CPetSkillCertificationYiWang = {}
CPetSkillCertificationYiWang.__index = CPetSkillCertificationYiWang



CPetSkillCertificationYiWang.PROTOCOL_TYPE = 817966

function CPetSkillCertificationYiWang.Create()
	print("enter CPetSkillCertificationYiWang create")
	return CPetSkillCertificationYiWang:new()
end
function CPetSkillCertificationYiWang:new()
	local self = {}
	setmetatable(self, CPetSkillCertificationYiWang)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.skillid = 0
	self.isconfirm = 0

	return self
end
function CPetSkillCertificationYiWang:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetSkillCertificationYiWang:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.skillid)
	_os_:marshal_int32(self.isconfirm)
	return _os_
end

function CPetSkillCertificationYiWang:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.skillid = _os_:unmarshal_int32()
	self.isconfirm = _os_:unmarshal_int32()
	return _os_
end

return CPetSkillCertificationYiWang
