require "utils.tableutil"
CReqBingFengRank = {}
CReqBingFengRank.__index = CReqBingFengRank



CReqBingFengRank.PROTOCOL_TYPE = 804556

function CReqBingFengRank.Create()
	print("enter CReqBingFengRank create")
	return CReqBingFengRank:new()
end
function CReqBingFengRank:new()
	local self = {}
	setmetatable(self, CReqBingFengRank)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.landid = 0

	return self
end
function CReqBingFengRank:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqBingFengRank:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.landid)
	return _os_
end

function CReqBingFengRank:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.landid = _os_:unmarshal_int32()
	return _os_
end

return CReqBingFengRank
