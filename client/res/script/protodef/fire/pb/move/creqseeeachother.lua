require "utils.tableutil"
CReqSeeEachOther = {}
CReqSeeEachOther.__index = CReqSeeEachOther



CReqSeeEachOther.PROTOCOL_TYPE = 790486

function CReqSeeEachOther.Create()
	print("enter CReqSeeEachOther create")
	return CReqSeeEachOther:new()
end
function CReqSeeEachOther:new()
	local self = {}
	setmetatable(self, CReqSeeEachOther)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CReqSeeEachOther:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqSeeEachOther:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CReqSeeEachOther:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CReqSeeEachOther
