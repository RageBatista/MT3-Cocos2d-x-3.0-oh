require "utils.tableutil"
CGetHuobanDetailInfo = {}
CGetHuobanDetailInfo.__index = CGetHuobanDetailInfo



CGetHuobanDetailInfo.PROTOCOL_TYPE = 818834

function CGetHuobanDetailInfo.Create()
	print("enter CGetHuobanDetailInfo create")
	return CGetHuobanDetailInfo:new()
end
function CGetHuobanDetailInfo:new()
	local self = {}
	setmetatable(self, CGetHuobanDetailInfo)
	self.type = self.PROTOCOL_TYPE
	self.huobanid = 0

	return self
end
function CGetHuobanDetailInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetHuobanDetailInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huobanid)
	return _os_
end

function CGetHuobanDetailInfo:unmarshal(_os_)
	self.huobanid = _os_:unmarshal_int32()
	return _os_
end

return CGetHuobanDetailInfo
