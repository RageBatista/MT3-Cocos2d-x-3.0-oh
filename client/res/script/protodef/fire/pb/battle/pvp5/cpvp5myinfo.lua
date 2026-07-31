require "utils.tableutil"
CPvP5MyInfo = {}
CPvP5MyInfo.__index = CPvP5MyInfo



CPvP5MyInfo.PROTOCOL_TYPE = 793663

function CPvP5MyInfo.Create()
	print("enter CPvP5MyInfo create")
	return CPvP5MyInfo:new()
end
function CPvP5MyInfo:new()
	local self = {}
	setmetatable(self, CPvP5MyInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPvP5MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP5MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPvP5MyInfo:unmarshal(_os_)
	return _os_
end

return CPvP5MyInfo
