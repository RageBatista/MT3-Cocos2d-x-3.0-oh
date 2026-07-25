require "utils.tableutil"
CVoteCandidate = {}
CVoteCandidate.__index = CVoteCandidate



CVoteCandidate.PROTOCOL_TYPE = 810436

function CVoteCandidate.Create()
	print("enter CVoteCandidate create")
	return CVoteCandidate:new()
end
function CVoteCandidate:new()
	local self = {}
	setmetatable(self, CVoteCandidate)
	self.type = self.PROTOCOL_TYPE
	self.candidateid = 0
	self.shouxikey = 0

	return self
end
function CVoteCandidate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CVoteCandidate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.candidateid)
	_os_:marshal_int64(self.shouxikey)
	return _os_
end

function CVoteCandidate:unmarshal(_os_)
	self.candidateid = _os_:unmarshal_int64()
	self.shouxikey = _os_:unmarshal_int64()
	return _os_
end

return CVoteCandidate
