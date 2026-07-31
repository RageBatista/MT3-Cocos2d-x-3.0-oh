require "utils.tableutil"
SBingFengLandInfo = {}
SBingFengLandInfo.__index = SBingFengLandInfo



SBingFengLandInfo.PROTOCOL_TYPE = 804552

function SBingFengLandInfo.Create()
	print("enter SBingFengLandInfo create")
	return SBingFengLandInfo:new()
end
function SBingFengLandInfo:new()
	local self = {}
	setmetatable(self, SBingFengLandInfo)
	self.type = self.PROTOCOL_TYPE
	self.ranktype = 0
	self.landid = 0
	self.lastrank = 0
	self.receiveaward = 0
	self.stage = 0
	self.yesterdaystage = 0
	self.entertimes = 0
	self.vip = 0

	return self
end
function SBingFengLandInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBingFengLandInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ranktype)
	_os_:marshal_int32(self.landid)
	_os_:marshal_int32(self.lastrank)
	_os_:marshal_int32(self.receiveaward)
	_os_:marshal_int32(self.stage)
	_os_:marshal_int32(self.yesterdaystage)
	_os_:marshal_int32(self.entertimes)
	_os_:marshal_int32(self.vip)
	return _os_
end

function SBingFengLandInfo:unmarshal(_os_)
	self.ranktype = _os_:unmarshal_int32()
	self.landid = _os_:unmarshal_int32()
	self.lastrank = _os_:unmarshal_int32()
	self.receiveaward = _os_:unmarshal_int32()
	self.stage = _os_:unmarshal_int32()
	self.yesterdaystage = _os_:unmarshal_int32()
	self.entertimes = _os_:unmarshal_int32()
	self.vip = _os_:unmarshal_int32()
	return _os_
end

return SBingFengLandInfo
