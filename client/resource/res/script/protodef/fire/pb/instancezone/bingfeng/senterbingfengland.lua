require "utils.tableutil"
SEnterBingFengLand = {}
SEnterBingFengLand.__index = SEnterBingFengLand



SEnterBingFengLand.PROTOCOL_TYPE = 804559

function SEnterBingFengLand.Create()
	print("enter SEnterBingFengLand create")
	return SEnterBingFengLand:new()
end
function SEnterBingFengLand:new()
	local self = {}
	setmetatable(self, SEnterBingFengLand)
	self.type = self.PROTOCOL_TYPE
	self.landid = 0
	self.stage = 0
	self.autogo = 0
	self.finishstage = 0

	return self
end
function SEnterBingFengLand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SEnterBingFengLand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.landid)
	_os_:marshal_int32(self.stage)
	_os_:marshal_int32(self.autogo)
	_os_:marshal_int32(self.finishstage)
	return _os_
end

function SEnterBingFengLand:unmarshal(_os_)
	self.landid = _os_:unmarshal_int32()
	self.stage = _os_:unmarshal_int32()
	self.autogo = _os_:unmarshal_int32()
	self.finishstage = _os_:unmarshal_int32()
	return _os_
end

return SEnterBingFengLand
