require "utils.tableutil"
LogBean = {}
LogBean.__index = LogBean


function LogBean:new()
	local self = {}
	setmetatable(self, LogBean)
	self.itemid = 0
	self.num = 0
	self.price = 0
	self.level = 0

	return self
end
function LogBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.price)
	_os_:marshal_int32(self.level)
	return _os_
end

function LogBean:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	return _os_
end

return LogBean
