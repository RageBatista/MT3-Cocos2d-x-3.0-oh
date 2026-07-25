require "utils.tableutil"
MasterPrenticeBaseData = {}
MasterPrenticeBaseData.__index = MasterPrenticeBaseData


function MasterPrenticeBaseData:new()
	local self = {}
	setmetatable(self, MasterPrenticeBaseData)
	self.roleid = 0
	self.nickname = "" 
	self.level = 0

	return self
end
function MasterPrenticeBaseData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.nickname)
	_os_:marshal_int32(self.level)
	return _os_
end

function MasterPrenticeBaseData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	self.level = _os_:unmarshal_int32()
	return _os_
end

return MasterPrenticeBaseData
