require "utils.tableutil"
SRefreshUserExp = {}
SRefreshUserExp.__index = SRefreshUserExp



SRefreshUserExp.PROTOCOL_TYPE = 786445

function SRefreshUserExp.Create()
	print("enter SRefreshUserExp create")
	return SRefreshUserExp:new()
end
function SRefreshUserExp:new()
	local self = {}
	setmetatable(self, SRefreshUserExp)
	self.type = self.PROTOCOL_TYPE
	self.curexp = 0

	return self
end
function SRefreshUserExp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshUserExp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.curexp)
	return _os_
end

function SRefreshUserExp:unmarshal(_os_)
	self.curexp = _os_:unmarshal_int64()
	return _os_
end

return SRefreshUserExp
