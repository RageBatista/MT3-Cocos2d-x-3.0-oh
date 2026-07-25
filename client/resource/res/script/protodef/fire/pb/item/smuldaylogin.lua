require "utils.tableutil"
SMulDayLogin = {}
SMulDayLogin.__index = SMulDayLogin



SMulDayLogin.PROTOCOL_TYPE = 787731

function SMulDayLogin.Create()
	print("enter SMulDayLogin create")
	return SMulDayLogin:new()
end
function SMulDayLogin:new()
	local self = {}
	setmetatable(self, SMulDayLogin)
	self.type = self.PROTOCOL_TYPE
	self.logindays = 0
	self.rewardmap = {}

	return self
end
function SMulDayLogin:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMulDayLogin:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.logindays)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.rewardmap))
	for k,v in pairs(self.rewardmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SMulDayLogin:unmarshal(_os_)
	self.logindays = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_rewardmap=0,_os_null_rewardmap
	_os_null_rewardmap, sizeof_rewardmap = _os_: uncompact_uint32(sizeof_rewardmap)
	for k = 1,sizeof_rewardmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.rewardmap[newkey] = newvalue
	end
	return _os_
end

return SMulDayLogin
