require "utils.tableutil"
CCampPK = {}
CCampPK.__index = CCampPK



CCampPK.PROTOCOL_TYPE = 806562

function CCampPK.Create()
	print("enter CCampPK create")
	return CCampPK:new()
end
function CCampPK:new()
	local self = {}
	setmetatable(self, CCampPK)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CCampPK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCampPK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CCampPK:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CCampPK
