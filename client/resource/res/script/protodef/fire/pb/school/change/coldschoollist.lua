require "utils.tableutil"
COldSchoolList = {}
COldSchoolList.__index = COldSchoolList



COldSchoolList.PROTOCOL_TYPE = 810483

function COldSchoolList.Create()
	print("enter COldSchoolList create")
	return COldSchoolList:new()
end
function COldSchoolList:new()
	local self = {}
	setmetatable(self, COldSchoolList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COldSchoolList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COldSchoolList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COldSchoolList:unmarshal(_os_)
	return _os_
end

return COldSchoolList
