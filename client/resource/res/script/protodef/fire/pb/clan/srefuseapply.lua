require "utils.tableutil"
SRefuseApply = {}
SRefuseApply.__index = SRefuseApply



SRefuseApply.PROTOCOL_TYPE = 808458

function SRefuseApply.Create()
	print("enter SRefuseApply create")
	return SRefuseApply:new()
end
function SRefuseApply:new()
	local self = {}
	setmetatable(self, SRefuseApply)
	self.type = self.PROTOCOL_TYPE
	self.applyroleid = 0

	return self
end
function SRefuseApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefuseApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.applyroleid)
	return _os_
end

function SRefuseApply:unmarshal(_os_)
	self.applyroleid = _os_:unmarshal_int64()
	return _os_
end

return SRefuseApply
