require "utils.tableutil"
CSearchMaster = {}
CSearchMaster.__index = CSearchMaster



CSearchMaster.PROTOCOL_TYPE = 816437

function CSearchMaster.Create()
	print("enter CSearchMaster create")
	return CSearchMaster:new()
end
function CSearchMaster:new()
	local self = {}
	setmetatable(self, CSearchMaster)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0

	return self
end
function CSearchMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSearchMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	return _os_
end

function CSearchMaster:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	return _os_
end

return CSearchMaster
