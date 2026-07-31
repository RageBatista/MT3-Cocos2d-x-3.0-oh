require "utils.tableutil"
ExchangeCodeRetInfo = {}
ExchangeCodeRetInfo.__index = ExchangeCodeRetInfo


function ExchangeCodeRetInfo:new()
	local self = {}
	setmetatable(self, ExchangeCodeRetInfo)
	self.itemtype = 0
	self.itemid = 0
	self.itemcount = 0
	self.preinfos = "" 

	return self
end
function ExchangeCodeRetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int64(self.itemid)
	_os_:marshal_int32(self.itemcount)
	_os_:marshal_wstring(self.preinfos)
	return _os_
end

function ExchangeCodeRetInfo:unmarshal(_os_)
	self.itemtype = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int64()
	self.itemcount = _os_:unmarshal_int32()
	self.preinfos = _os_:unmarshal_wstring(self.preinfos)
	return _os_
end

return ExchangeCodeRetInfo
