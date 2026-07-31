require "utils.tableutil"
SGetBingFengDetail = {}
SGetBingFengDetail.__index = SGetBingFengDetail



SGetBingFengDetail.PROTOCOL_TYPE = 804566

function SGetBingFengDetail.Create()
	print("enter SGetBingFengDetail create")
	return SGetBingFengDetail:new()
end
function SGetBingFengDetail:new()
	local self = {}
	setmetatable(self, SGetBingFengDetail)
	self.type = self.PROTOCOL_TYPE
	self.rolename = "" 
	self.usetime = 0
	self.stagestate = 0
	self.myusetime = 0

	return self
end
function SGetBingFengDetail:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetBingFengDetail:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.usetime)
	_os_:marshal_short(self.stagestate)
	_os_:marshal_int32(self.myusetime)
	return _os_
end

function SGetBingFengDetail:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.usetime = _os_:unmarshal_int32()
	self.stagestate = _os_:unmarshal_short()
	self.myusetime = _os_:unmarshal_int32()
	return _os_
end

return SGetBingFengDetail
