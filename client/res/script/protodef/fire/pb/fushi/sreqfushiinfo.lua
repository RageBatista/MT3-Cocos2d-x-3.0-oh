require "utils.tableutil"
SReqFushiInfo = {}
SReqFushiInfo.__index = SReqFushiInfo



SReqFushiInfo.PROTOCOL_TYPE = 812491

function SReqFushiInfo.Create()
	print("enter SReqFushiInfo create")
	return SReqFushiInfo:new()
end
function SReqFushiInfo:new()
	local self = {}
	setmetatable(self, SReqFushiInfo)
	self.type = self.PROTOCOL_TYPE
	self.balance = 0
	self.genbalance = 0
	self.firstsave = 0
	self.saveamt = 0

	return self
end
function SReqFushiInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqFushiInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.balance)
	_os_:marshal_int32(self.genbalance)
	_os_:marshal_int32(self.firstsave)
	_os_:marshal_int32(self.saveamt)
	return _os_
end

function SReqFushiInfo:unmarshal(_os_)
	self.balance = _os_:unmarshal_int32()
	self.genbalance = _os_:unmarshal_int32()
	self.firstsave = _os_:unmarshal_int32()
	self.saveamt = _os_:unmarshal_int32()
	return _os_
end

return SReqFushiInfo
