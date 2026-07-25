require "utils.tableutil"
GoldOrderInfo = {}
GoldOrderInfo.__index = GoldOrderInfo


function GoldOrderInfo:new()
	local self = {}
	setmetatable(self, GoldOrderInfo)
	self.pid = 0
	self.number = 0
	self.price = 0
    self.rolename=""
	self.time = 0
	self.roleid = 0

	return self
end
function GoldOrderInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	_os_:marshal_int64(self.number)
	_os_:marshal_int64(self.price)
	_os_:marshal_int64(self.time)
  	_os_:marshal_wstring(self.rolename)
   _os_:marshal_int64(self.roleid)
	return _os_
end

function GoldOrderInfo:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	self.number = _os_:unmarshal_int64()
	self.price = _os_:unmarshal_int64()
	self.time = _os_:unmarshal_int64()
    self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return GoldOrderInfo
