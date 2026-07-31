require "utils.tableutil"
CUseTreasureMap = {}
CUseTreasureMap.__index = CUseTreasureMap



CUseTreasureMap.PROTOCOL_TYPE = 805532

function CUseTreasureMap.Create()
	print("enter CUseTreasureMap create")
	return CUseTreasureMap:new()
end
function CUseTreasureMap:new()
	local self = {}
	setmetatable(self, CUseTreasureMap)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0
	self.maptype = 0

	return self
end
function CUseTreasureMap:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUseTreasureMap:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.maptype)
	return _os_
end

function CUseTreasureMap:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	self.maptype = _os_:unmarshal_int32()
	return _os_
end

return CUseTreasureMap
