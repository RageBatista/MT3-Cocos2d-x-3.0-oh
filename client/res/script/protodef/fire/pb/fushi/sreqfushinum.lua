require "utils.tableutil"
SReqFushiNum = {}
SReqFushiNum.__index = SReqFushiNum



SReqFushiNum.PROTOCOL_TYPE = 812442

function SReqFushiNum.Create()
	print("enter SReqFushiNum create")
	return SReqFushiNum:new()
end
function SReqFushiNum:new()
	local self = {}
	setmetatable(self, SReqFushiNum)
	self.type = self.PROTOCOL_TYPE
	self.num = 0
	self.bindnum = 0
	self.totalnum = 0

	return self
end
function SReqFushiNum:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqFushiNum:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.bindnum)
	_os_:marshal_int32(self.totalnum)
	return _os_
end

function SReqFushiNum:unmarshal(_os_)
	self.num = _os_:unmarshal_int32()
	self.bindnum = _os_:unmarshal_int32()
	self.totalnum = _os_:unmarshal_int32()
	return _os_
end

return SReqFushiNum
