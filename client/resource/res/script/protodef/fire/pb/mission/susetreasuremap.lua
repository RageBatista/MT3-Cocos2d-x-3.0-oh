require "utils.tableutil"
SUseTreasureMap = {}
SUseTreasureMap.__index = SUseTreasureMap



SUseTreasureMap.PROTOCOL_TYPE = 805533

function SUseTreasureMap.Create()
	print("enter SUseTreasureMap create")
	return SUseTreasureMap:new()
end
function SUseTreasureMap:new()
	local self = {}
	setmetatable(self, SUseTreasureMap)
	self.type = self.PROTOCOL_TYPE
	self.awardid = 0
	self.maptype = 0

	return self
end
function SUseTreasureMap:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUseTreasureMap:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.awardid)
	_os_:marshal_int32(self.maptype)
	return _os_
end

function SUseTreasureMap:unmarshal(_os_)
	self.awardid = _os_:unmarshal_int32()
	self.maptype = _os_:unmarshal_int32()
	return _os_
end

return SUseTreasureMap
