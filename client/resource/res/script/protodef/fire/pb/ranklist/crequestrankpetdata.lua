require "utils.tableutil"
CRequestRankPetData = {}
CRequestRankPetData.__index = CRequestRankPetData



CRequestRankPetData.PROTOCOL_TYPE = 810240

function CRequestRankPetData.Create()
	print("enter CRequestRankPetData create")
	return CRequestRankPetData:new()
end
function CRequestRankPetData:new()
	local self = {}
	setmetatable(self, CRequestRankPetData)
	self.type = self.PROTOCOL_TYPE
	self.uniquepetid = 0

	return self
end
function CRequestRankPetData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRankPetData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniquepetid)
	return _os_
end

function CRequestRankPetData:unmarshal(_os_)
	self.uniquepetid = _os_:unmarshal_int64()
	return _os_
end

return CRequestRankPetData
