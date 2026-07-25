require "utils.tableutil"
HookExpData = {}
HookExpData.__index = HookExpData


function HookExpData:new()
	local self = {}
	setmetatable(self, HookExpData)
	self.cangetdpoint = 0
	self.getdpoint = 0
	self.offlineexp = 0

	return self
end
function HookExpData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.cangetdpoint)
	_os_:marshal_short(self.getdpoint)
	_os_:marshal_int64(self.offlineexp)
	return _os_
end

function HookExpData:unmarshal(_os_)
	self.cangetdpoint = _os_:unmarshal_short()
	self.getdpoint = _os_:unmarshal_short()
	self.offlineexp = _os_:unmarshal_int64()
	return _os_
end

return HookExpData
