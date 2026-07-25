require "utils.tableutil"
CGetBingFengDetail = {}
CGetBingFengDetail.__index = CGetBingFengDetail



CGetBingFengDetail.PROTOCOL_TYPE = 804565

function CGetBingFengDetail.Create()
	print("enter CGetBingFengDetail create")
	return CGetBingFengDetail:new()
end
function CGetBingFengDetail:new()
	local self = {}
	setmetatable(self, CGetBingFengDetail)
	self.type = self.PROTOCOL_TYPE
	self.landid = 0
	self.stage = 0

	return self
end
function CGetBingFengDetail:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetBingFengDetail:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.landid)
	_os_:marshal_int32(self.stage)
	return _os_
end

function CGetBingFengDetail:unmarshal(_os_)
	self.landid = _os_:unmarshal_int32()
	self.stage = _os_:unmarshal_int32()
	return _os_
end

return CGetBingFengDetail
