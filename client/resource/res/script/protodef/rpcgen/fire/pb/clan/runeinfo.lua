require "utils.tableutil"
RuneInfo = {}
RuneInfo.__index = RuneInfo


function RuneInfo:new()
	local self = {}
	setmetatable(self, RuneInfo)
	self.roleid = 0
	self.rolename = "" 
	self.targetroleid = 0
	self.targetrolename = "" 
	self.level = 0
	self.school = 0
	self.shape = 0
	self.givenum = 0
	self.acceptnum = 0
	self.actiontype = 0
	self.requesttime = 0
	self.itemid = 0
	self.itemlevel = 0

	return self
end
function RuneInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int64(self.targetroleid)
	_os_:marshal_wstring(self.targetrolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.givenum)
	_os_:marshal_int32(self.acceptnum)
	_os_:marshal_int32(self.actiontype)
	_os_:marshal_int64(self.requesttime)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemlevel)
	return _os_
end

function RuneInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.targetroleid = _os_:unmarshal_int64()
	self.targetrolename = _os_:unmarshal_wstring(self.targetrolename)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.givenum = _os_:unmarshal_int32()
	self.acceptnum = _os_:unmarshal_int32()
	self.actiontype = _os_:unmarshal_int32()
	self.requesttime = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.itemlevel = _os_:unmarshal_int32()
	return _os_
end

return RuneInfo
