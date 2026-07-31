require "utils.tableutil"
SAddTreasureMap = {}
SAddTreasureMap.__index = SAddTreasureMap



SAddTreasureMap.PROTOCOL_TYPE = 805545

function SAddTreasureMap.Create()
	print("enter SAddTreasureMap create")
	return SAddTreasureMap:new()
end
function SAddTreasureMap:new()
	local self = {}
	setmetatable(self, SAddTreasureMap)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SAddTreasureMap:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddTreasureMap:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SAddTreasureMap:unmarshal(_os_)
	return _os_
end

return SAddTreasureMap
