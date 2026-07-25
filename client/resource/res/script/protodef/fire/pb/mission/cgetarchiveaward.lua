require "utils.tableutil"
CGetArchiveAward = {}
CGetArchiveAward.__index = CGetArchiveAward



CGetArchiveAward.PROTOCOL_TYPE = 805542

function CGetArchiveAward.Create()
	print("enter CGetArchiveAward create")
	return CGetArchiveAward:new()
end
function CGetArchiveAward:new()
	local self = {}
	setmetatable(self, CGetArchiveAward)
	self.type = self.PROTOCOL_TYPE
	self.archiveid = 0

	return self
end
function CGetArchiveAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetArchiveAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.archiveid)
	return _os_
end

function CGetArchiveAward:unmarshal(_os_)
	self.archiveid = _os_:unmarshal_int32()
	return _os_
end

return CGetArchiveAward
