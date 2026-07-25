require "utils.tableutil"
TitleInfo = {}
TitleInfo.__index = TitleInfo


function TitleInfo:new()
	local self = {}
	setmetatable(self, TitleInfo)
	self.titleid = 0
	self.name = "" 
	self.availtime = 0

	return self
end
function TitleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.titleid)
	_os_:marshal_wstring(self.name)
	_os_:marshal_int64(self.availtime)
	return _os_
end

function TitleInfo:unmarshal(_os_)
	self.titleid = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	self.availtime = _os_:unmarshal_int64()
	return _os_
end

return TitleInfo
