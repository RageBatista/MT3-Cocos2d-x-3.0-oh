require "utils.tableutil"
CAcceptOrRefuseApply = {}
CAcceptOrRefuseApply.__index = CAcceptOrRefuseApply



CAcceptOrRefuseApply.PROTOCOL_TYPE = 808457

function CAcceptOrRefuseApply.Create()
	print("enter CAcceptOrRefuseApply create")
	return CAcceptOrRefuseApply:new()
end
function CAcceptOrRefuseApply:new()
	local self = {}
	setmetatable(self, CAcceptOrRefuseApply)
	self.type = self.PROTOCOL_TYPE
	self.applyroleid = 0
	self.accept = 0

	return self
end
function CAcceptOrRefuseApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptOrRefuseApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.applyroleid)
	_os_:marshal_char(self.accept)
	return _os_
end

function CAcceptOrRefuseApply:unmarshal(_os_)
	self.applyroleid = _os_:unmarshal_int64()
	self.accept = _os_:unmarshal_char()
	return _os_
end

return CAcceptOrRefuseApply
