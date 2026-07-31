require "utils.tableutil"
CRecommendFriend = {}
CRecommendFriend.__index = CRecommendFriend



CRecommendFriend.PROTOCOL_TYPE = 806576

function CRecommendFriend.Create()
	print("enter CRecommendFriend create")
	return CRecommendFriend:new()
end
function CRecommendFriend:new()
	local self = {}
	setmetatable(self, CRecommendFriend)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRecommendFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRecommendFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRecommendFriend:unmarshal(_os_)
	return _os_
end

return CRecommendFriend
