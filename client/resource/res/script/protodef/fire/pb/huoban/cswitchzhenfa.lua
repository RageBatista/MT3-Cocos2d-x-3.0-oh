require "utils.tableutil"
CSwitchZhenfa = {}
CSwitchZhenfa.__index = CSwitchZhenfa



CSwitchZhenfa.PROTOCOL_TYPE = 818842

function CSwitchZhenfa.Create()
	print("enter CSwitchZhenfa create")
	return CSwitchZhenfa:new()
end
function CSwitchZhenfa:new()
	local self = {}
	setmetatable(self, CSwitchZhenfa)
	self.type = self.PROTOCOL_TYPE
	self.zhenrongid = 0
	self.zhenfaid = 0

	return self
end
function CSwitchZhenfa:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSwitchZhenfa:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenrongid)
	_os_:marshal_int32(self.zhenfaid)
	return _os_
end

function CSwitchZhenfa:unmarshal(_os_)
	self.zhenrongid = _os_:unmarshal_int32()
	self.zhenfaid = _os_:unmarshal_int32()
	return _os_
end

return CSwitchZhenfa
