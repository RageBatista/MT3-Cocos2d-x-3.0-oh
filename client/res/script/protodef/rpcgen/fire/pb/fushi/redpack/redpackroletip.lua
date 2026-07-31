require "utils.tableutil"
RedPackRoleTip = {}
RedPackRoleTip.__index = RedPackRoleTip


function RedPackRoleTip:new()
	local self = {}
	setmetatable(self, RedPackRoleTip)
	self.modeltype = 0
	self.redpackid = "" 
	self.rolename = "" 
	self.fushi = 0

	return self
end
function RedPackRoleTip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.fushi)
	return _os_
end

function RedPackRoleTip:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.fushi = _os_:unmarshal_int32()
	return _os_
end

return RedPackRoleTip
