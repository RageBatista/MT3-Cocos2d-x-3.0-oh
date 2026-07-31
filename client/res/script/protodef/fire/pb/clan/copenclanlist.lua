require "utils.tableutil"
COpenClanList = {}
COpenClanList.__index = COpenClanList



COpenClanList.PROTOCOL_TYPE = 808447

function COpenClanList.Create()
	print("enter COpenClanList create")
	return COpenClanList:new()
end
function COpenClanList:new()
	local self = {}
	setmetatable(self, COpenClanList)
	self.type = self.PROTOCOL_TYPE
	self.currpage = 0

	return self
end
function COpenClanList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenClanList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.currpage)
	return _os_
end

function COpenClanList:unmarshal(_os_)
	self.currpage = _os_:unmarshal_int32()
	return _os_
end

return COpenClanList
