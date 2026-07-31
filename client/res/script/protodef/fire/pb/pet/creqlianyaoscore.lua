require "utils.tableutil"
CReqLianYaoScore = {}
CReqLianYaoScore.__index = CReqLianYaoScore



CReqLianYaoScore.PROTOCOL_TYPE = 810515

function CReqLianYaoScore.Create()
	print("enter CReqLianYaoScore create")
	return CReqLianYaoScore:new()
end
function CReqLianYaoScore:new()
	local self = {}
	setmetatable(self, CReqLianYaoScore)
	self.type = self.PROTOCOL_TYPE
 

	return self
end
function CReqLianYaoScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLianYaoScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
 
	return _os_
end

function CReqLianYaoScore:unmarshal(_os_)
 
	return _os_
end

return CReqLianYaoScore
