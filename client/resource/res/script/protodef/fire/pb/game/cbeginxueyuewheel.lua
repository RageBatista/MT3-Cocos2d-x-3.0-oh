require "utils.tableutil"
CBeginXueYueWheel = {}
CBeginXueYueWheel.__index = CBeginXueYueWheel



CBeginXueYueWheel.PROTOCOL_TYPE = 810366

function CBeginXueYueWheel.Create()
	print("enter CBeginXueYueWheel create")
	return CBeginXueYueWheel:new()
end
function CBeginXueYueWheel:new()
	local self = {}
	setmetatable(self, CBeginXueYueWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.boxtype = 0
	self.shilian = 0
	return self
end
function CBeginXueYueWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBeginXueYueWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.boxtype)
	_os_:marshal_int32(self.shilian)
	return _os_
end

function CBeginXueYueWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.boxtype = _os_:unmarshal_int32()
	self.shilian = _os_:unmarshal_int32()
	return _os_
end

return CBeginXueYueWheel
