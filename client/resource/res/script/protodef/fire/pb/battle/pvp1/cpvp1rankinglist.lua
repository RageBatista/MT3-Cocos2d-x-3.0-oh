require "utils.tableutil"
CPvP1RankingList = {}
CPvP1RankingList.__index = CPvP1RankingList



CPvP1RankingList.PROTOCOL_TYPE = 793535

function CPvP1RankingList.Create()
	print("enter CPvP1RankingList create")
	return CPvP1RankingList:new()
end
function CPvP1RankingList:new()
	local self = {}
	setmetatable(self, CPvP1RankingList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPvP1RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP1RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPvP1RankingList:unmarshal(_os_)
	return _os_
end

return CPvP1RankingList
