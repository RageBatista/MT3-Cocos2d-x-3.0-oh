require "utils.tableutil"
BingFengRankData = {}
BingFengRankData.__index = BingFengRankData


function BingFengRankData:new()
	local self = {}
	setmetatable(self, BingFengRankData)
	self.shool = 0
	self.rank = 0
	self.roleid = 0
	self.rolename = "" 
	self.stage = 0
	self.times = 0

	return self
end
function BingFengRankData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shool)
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.stage)
	_os_:marshal_int32(self.times)
	return _os_
end

function BingFengRankData:unmarshal(_os_)
	self.shool = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.stage = _os_:unmarshal_int32()
	self.times = _os_:unmarshal_int32()
	return _os_
end

return BingFengRankData
