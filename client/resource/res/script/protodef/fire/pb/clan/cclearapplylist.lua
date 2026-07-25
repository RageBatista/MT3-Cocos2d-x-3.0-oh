require "utils.tableutil"
CClearApplyList = {}
CClearApplyList.__index = CClearApplyList



CClearApplyList.PROTOCOL_TYPE = 808455

function CClearApplyList.Create()
	print("enter CClearApplyList create")
	return CClearApplyList:new()
end
function CClearApplyList:new()
	local self = {}
	setmetatable(self, CClearApplyList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CClearApplyList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClearApplyList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CClearApplyList:unmarshal(_os_)
	return _os_
end

return CClearApplyList
