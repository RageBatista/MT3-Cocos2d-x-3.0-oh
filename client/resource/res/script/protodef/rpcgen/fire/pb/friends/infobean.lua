require "utils.tableutil"
InfoBean = {}
InfoBean.__index = InfoBean


function InfoBean:new()
	local self = {}
	setmetatable(self, InfoBean)
	self.roleid = 0
	self.name = "" 
	self.rolelevel = 0
	self.school = 0
	self.online = 0
	self.shape = 0
	self.camp = 0
	self.relation = 0
	self.factionid = 0
	self.factionname = "" 

	return self
end
function InfoBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.name)
	_os_:marshal_short(self.rolelevel)
	_os_:marshal_char(self.school)
	_os_:marshal_char(self.online)
	_os_:marshal_int32(self.shape)
	_os_:marshal_char(self.camp)
	_os_:marshal_short(self.relation)
	_os_:marshal_int64(self.factionid)
	_os_:marshal_wstring(self.factionname)
	return _os_
end

function InfoBean:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.name = _os_:unmarshal_wstring(self.name)
	self.rolelevel = _os_:unmarshal_short()
	self.school = _os_:unmarshal_char()
	self.online = _os_:unmarshal_char()
	self.shape = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_char()
	self.relation = _os_:unmarshal_short()
	self.factionid = _os_:unmarshal_int64()
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	return _os_
end

return InfoBean
