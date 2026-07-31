require "utils.tableutil"
CShenShouDuiHuan = {}
CShenShouDuiHuan.__index = CShenShouDuiHuan



CShenShouDuiHuan.PROTOCOL_TYPE = 788528

function CShenShouDuiHuan.Create()
	print("enter CShenShouDuiHuan create")
	return CShenShouDuiHuan:new()
end
function CShenShouDuiHuan:new()
	local self = {}
	setmetatable(self, CShenShouDuiHuan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CShenShouDuiHuan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShenShouDuiHuan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CShenShouDuiHuan:unmarshal(_os_)
	return _os_
end

return CShenShouDuiHuan
