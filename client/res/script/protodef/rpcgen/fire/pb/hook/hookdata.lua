require "utils.tableutil"
HookData = {}
HookData.__index = HookData


function HookData:new()
	local self = {}
	setmetatable(self, HookData)
	self.cangetdpoint = 0
	self.getdpoint = 0
	self.isautobattle = 0
	self.charoptype = 0
	self.charopid = 0
	self.petoptype = 0
	self.petopid = 0
	self.offlineexp = 0

	return self
end
function HookData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.cangetdpoint)
	_os_:marshal_short(self.getdpoint)
	_os_:marshal_char(self.isautobattle)
	_os_:marshal_short(self.charoptype)
	_os_:marshal_int32(self.charopid)
	_os_:marshal_short(self.petoptype)
	_os_:marshal_int32(self.petopid)
	_os_:marshal_int64(self.offlineexp)
	return _os_
end

function HookData:unmarshal(_os_)
	self.cangetdpoint = _os_:unmarshal_short()
	self.getdpoint = _os_:unmarshal_short()
	self.isautobattle = _os_:unmarshal_char()
	self.charoptype = _os_:unmarshal_short()
	self.charopid = _os_:unmarshal_int32()
	self.petoptype = _os_:unmarshal_short()
	self.petopid = _os_:unmarshal_int32()
	self.offlineexp = _os_:unmarshal_int64()
	return _os_
end

return HookData
