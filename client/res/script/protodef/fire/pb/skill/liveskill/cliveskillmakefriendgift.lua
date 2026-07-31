require "utils.tableutil"
CLiveSkillMakeFriendGift = {}
CLiveSkillMakeFriendGift.__index = CLiveSkillMakeFriendGift



CLiveSkillMakeFriendGift.PROTOCOL_TYPE = 800523

function CLiveSkillMakeFriendGift.Create()
	print("enter CLiveSkillMakeFriendGift create")
	return CLiveSkillMakeFriendGift:new()
end
function CLiveSkillMakeFriendGift:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeFriendGift)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLiveSkillMakeFriendGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeFriendGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLiveSkillMakeFriendGift:unmarshal(_os_)
	return _os_
end

return CLiveSkillMakeFriendGift
