require "utils.tableutil"
CZuoQiYongYou = {}
CZuoQiYongYou.__index = CZuoQiYongYou



CZuoQiYongYou.PROTOCOL_TYPE = 800021

function CZuoQiYongYou.Create()
	print("enter CChangeSchool create")
	return CZuoQiYongYou:new()
end
function CZuoQiYongYou:new()
	local self = {}
	setmetatable(self, CZuoQiYongYou)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CZuoQiYongYou:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CZuoQiYongYou:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CZuoQiYongYou:unmarshal(_os_)
	return _os_
end

return CZuoQiYongYou
