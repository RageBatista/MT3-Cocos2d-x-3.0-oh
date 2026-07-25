require "utils.tableutil"
CQueryFestivalData = {}
CQueryFestivalData.__index = CQueryFestivalData



CQueryFestivalData.PROTOCOL_TYPE = 810535

function CQueryFestivalData.Create()
	print("enter CQueryFestivalData create")
	return CQueryFestivalData:new()
end
function CQueryFestivalData:new()
	local self = {}
	setmetatable(self, CQueryFestivalData)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQueryFestivalData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryFestivalData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQueryFestivalData:unmarshal(_os_)
	return _os_
end

return CQueryFestivalData
