require "utils.tableutil"
CPvP1MyInfo = {}
CPvP1MyInfo.__index = CPvP1MyInfo



CPvP1MyInfo.PROTOCOL_TYPE = 793533

function CPvP1MyInfo.Create()
	print("enter CPvP1MyInfo create")
	return CPvP1MyInfo:new()
end
function CPvP1MyInfo:new()
	local self = {}
	setmetatable(self, CPvP1MyInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPvP1MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP1MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPvP1MyInfo:unmarshal(_os_)
	return _os_
end

return CPvP1MyInfo
