require "utils.tableutil"
CPvP3MyInfo = {}
CPvP3MyInfo.__index = CPvP3MyInfo



CPvP3MyInfo.PROTOCOL_TYPE = 793633

function CPvP3MyInfo.Create()
	print("enter CPvP3MyInfo create")
	return CPvP3MyInfo:new()
end
function CPvP3MyInfo:new()
	local self = {}
	setmetatable(self, CPvP3MyInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPvP3MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP3MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPvP3MyInfo:unmarshal(_os_)
	return _os_
end

return CPvP3MyInfo
