require "utils.tableutil"
RedPackRankRecord = {}
RedPackRankRecord.__index = RedPackRankRecord


function RedPackRankRecord:new()
	local self = {}
	setmetatable(self, RedPackRankRecord)
	self.rank = 0
	self.roleid = 0
	self.rolename = "" 
	self.school = 0
	self.num = 0

	return self
end
function RedPackRankRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int64(self.num)
	return _os_
end

function RedPackRankRecord:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.school = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int64()
	return _os_
end

return RedPackRankRecord
