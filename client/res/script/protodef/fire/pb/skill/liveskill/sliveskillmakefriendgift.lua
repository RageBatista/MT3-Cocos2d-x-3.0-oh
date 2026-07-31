require "utils.tableutil"
SLiveSkillMakeFriendGift = {}
SLiveSkillMakeFriendGift.__index = SLiveSkillMakeFriendGift



SLiveSkillMakeFriendGift.PROTOCOL_TYPE = 800524

function SLiveSkillMakeFriendGift.Create()
	print("enter SLiveSkillMakeFriendGift create")
	return SLiveSkillMakeFriendGift:new()
end
function SLiveSkillMakeFriendGift:new()
	local self = {}
	setmetatable(self, SLiveSkillMakeFriendGift)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0

	return self
end
function SLiveSkillMakeFriendGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveSkillMakeFriendGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	return _os_
end

function SLiveSkillMakeFriendGift:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	return _os_
end

return SLiveSkillMakeFriendGift
