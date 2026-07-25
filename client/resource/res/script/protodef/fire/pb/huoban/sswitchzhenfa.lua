require "utils.tableutil"
SSwitchZhenfa = {}
SSwitchZhenfa.__index = SSwitchZhenfa



SSwitchZhenfa.PROTOCOL_TYPE = 818843

function SSwitchZhenfa.Create()
	print("enter SSwitchZhenfa create")
	return SSwitchZhenfa:new()
end
function SSwitchZhenfa:new()
	local self = {}
	setmetatable(self, SSwitchZhenfa)
	self.type = self.PROTOCOL_TYPE
	self.zhenrongid = 0
	self.zhenfaid = 0

	return self
end
function SSwitchZhenfa:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSwitchZhenfa:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenrongid)
	_os_:marshal_int32(self.zhenfaid)
	return _os_
end

function SSwitchZhenfa:unmarshal(_os_)
	self.zhenrongid = _os_:unmarshal_int32()
	self.zhenfaid = _os_:unmarshal_int32()
	return _os_
end

return SSwitchZhenfa
