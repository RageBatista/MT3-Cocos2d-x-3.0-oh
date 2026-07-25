require "utils.tableutil"
CGetDepotInfo = {}
CGetDepotInfo.__index = CGetDepotInfo



CGetDepotInfo.PROTOCOL_TYPE = 787769

function CGetDepotInfo.Create()
	print("enter CGetDepotInfo create")
	return CGetDepotInfo:new()
end
function CGetDepotInfo:new()
	local self = {}
	setmetatable(self, CGetDepotInfo)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0

	return self
end
function CGetDepotInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetDepotInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	return _os_
end

function CGetDepotInfo:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	return _os_
end

return CGetDepotInfo
