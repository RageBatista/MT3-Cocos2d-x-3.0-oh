require "utils.tableutil"
SReqLianYaoScore = {}
SReqLianYaoScore.__index = SReqLianYaoScore



SReqLianYaoScore.PROTOCOL_TYPE = 810516

function SReqLianYaoScore.Create()
	print("enter SReqLianYaoScore create")
	return SReqLianYaoScore:new()
end
function SReqLianYaoScore:new()
	local self = {}
	setmetatable(self, SReqLianYaoScore)
	self.type = self.PROTOCOL_TYPE
	self.score = 0

	return self
end
function SReqLianYaoScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqLianYaoScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.score)
	return _os_
end

function SReqLianYaoScore:unmarshal(_os_)
	self.score = _os_:unmarshal_int32()
	return _os_
end

return SReqLianYaoScore
