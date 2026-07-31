require "utils.tableutil"
RedPackInfo = {}
RedPackInfo.__index = RedPackInfo


function RedPackInfo:new()
	local self = {}
	setmetatable(self, RedPackInfo)
	self.redpackid = "" 
	self.roleid = 0
	self.rolename = "" 
	self.redpackdes = "" 
	self.redpackstate = 0
	self.fushi = 0

	return self
end
function RedPackInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.redpackid)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_wstring(self.redpackdes)
	_os_:marshal_int32(self.redpackstate)
	_os_:marshal_int32(self.fushi)
	return _os_
end

function RedPackInfo:unmarshal(_os_)
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.redpackdes = _os_:unmarshal_wstring(self.redpackdes)
	self.redpackstate = _os_:unmarshal_int32()
	self.fushi = _os_:unmarshal_int32()
	return _os_
end

return RedPackInfo
