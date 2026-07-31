require "utils.tableutil"
SRegMaster = {
	FAIL = 0,
	SUCCESS = 1
}
SRegMaster.__index = SRegMaster



SRegMaster.PROTOCOL_TYPE = 816433

function SRegMaster.Create()
	print("enter SRegMaster create")
	return SRegMaster:new()
end
function SRegMaster:new()
	local self = {}
	setmetatable(self, SRegMaster)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SRegMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRegMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function SRegMaster:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SRegMaster
