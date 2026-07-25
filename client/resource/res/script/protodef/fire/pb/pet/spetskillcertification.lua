require "utils.tableutil"
SPetSkillCertification = {}
SPetSkillCertification.__index = SPetSkillCertification



SPetSkillCertification.PROTOCOL_TYPE = 788520

function SPetSkillCertification.Create()
	print("enter SPetSkillCertification create")
	return SPetSkillCertification:new()
end
function SPetSkillCertification:new()
	local self = {}
	setmetatable(self, SPetSkillCertification)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.skillid = 0
	self.isconfirm = 0

	return self
end
function SPetSkillCertification:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetSkillCertification:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.skillid)
	_os_:marshal_int32(self.isconfirm)
	return _os_
end

function SPetSkillCertification:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.skillid = _os_:unmarshal_int32()
	self.isconfirm = _os_:unmarshal_int32()
	return _os_
end

return SPetSkillCertification
