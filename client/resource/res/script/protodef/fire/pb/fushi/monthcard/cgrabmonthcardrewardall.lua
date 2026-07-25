require "utils.tableutil"
CGrabMonthCardRewardAll = {}
CGrabMonthCardRewardAll.__index = CGrabMonthCardRewardAll



CGrabMonthCardRewardAll.PROTOCOL_TYPE = 812690

function CGrabMonthCardRewardAll.Create()
	print("enter CGrabMonthCardRewardAll create")
	return CGrabMonthCardRewardAll:new()
end
function CGrabMonthCardRewardAll:new()
	local self = {}
	setmetatable(self, CGrabMonthCardRewardAll)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGrabMonthCardRewardAll:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGrabMonthCardRewardAll:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGrabMonthCardRewardAll:unmarshal(_os_)
	return _os_
end

return CGrabMonthCardRewardAll
