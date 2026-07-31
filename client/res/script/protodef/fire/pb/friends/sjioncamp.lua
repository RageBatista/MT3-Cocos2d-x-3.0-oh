require "utils.tableutil"
SJionCamp = {}
SJionCamp.__index = SJionCamp



SJionCamp.PROTOCOL_TYPE = 806559

function SJionCamp.Create()
	print("enter SJionCamp create")
	return SJionCamp:new()
end
function SJionCamp:new()
	local self = {}
	setmetatable(self, SJionCamp)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.camptype = 0
	self.selecttype = 0

	return self
end
function SJionCamp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SJionCamp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.camptype)
	_os_:marshal_char(self.selecttype)
	return _os_
end

function SJionCamp:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.camptype = _os_:unmarshal_char()
	self.selecttype = _os_:unmarshal_char()
	return _os_
end

return SJionCamp
