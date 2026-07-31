require "utils.tableutil"
SUseXueYueKey = {}
SUseXueYueKey.__index = SUseXueYueKey



SUseXueYueKey.PROTOCOL_TYPE = 810370

function SUseXueYueKey.Create()
	print("enter SUseXueYueKey create")
	return SUseXueYueKey:new()
end
function SUseXueYueKey:new()
	local self = {}
	setmetatable(self, SUseXueYueKey)
	self.type = self.PROTOCOL_TYPE
	self.npckid = 0
	self.npckey = 0
	self.mapid = 0
	self.xpos = 0
	self.ypos = 0

	return self
end
function SUseXueYueKey:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUseXueYueKey:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.npckid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.mapid)
	_os_:marshal_int32(self.xpos)
	_os_:marshal_int32(self.ypos)
	return _os_
end

function SUseXueYueKey:unmarshal(_os_)
	self.npckid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.mapid = _os_:unmarshal_int32()
	self.xpos = _os_:unmarshal_int32()
	self.ypos = _os_:unmarshal_int32()
	return _os_
end

return SUseXueYueKey
