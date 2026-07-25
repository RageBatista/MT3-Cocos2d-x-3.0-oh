require "utils.tableutil"
CSwitchZhenrong = {}
CSwitchZhenrong.__index = CSwitchZhenrong



CSwitchZhenrong.PROTOCOL_TYPE = 818837

function CSwitchZhenrong.Create()
	print("enter CSwitchZhenrong create")
	return CSwitchZhenrong:new()
end
function CSwitchZhenrong:new()
	local self = {}
	setmetatable(self, CSwitchZhenrong)
	self.type = self.PROTOCOL_TYPE
	self.zhenrongid = 0

	return self
end
function CSwitchZhenrong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSwitchZhenrong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenrongid)
	return _os_
end

function CSwitchZhenrong:unmarshal(_os_)
	self.zhenrongid = _os_:unmarshal_int32()
	return _os_
end

return CSwitchZhenrong
