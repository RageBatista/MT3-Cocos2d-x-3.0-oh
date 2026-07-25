require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
SingleCharacterBasic = {}
SingleCharacterBasic.__index = SingleCharacterBasic


function SingleCharacterBasic:new()
	local self = {}
	setmetatable(self, SingleCharacterBasic)
	self.roleid = 0
	self.level = 0
	self.name = "" 
	self.school = 0
	self.position = Pos1:new()
	self.camp = 0

	return self
end
function SingleCharacterBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.level)
	_os_:marshal_wstring(self.name)
	_os_:marshal_int32(self.school)
	----------------marshal bean
	self.position:marshal(_os_) 
	_os_:marshal_char(self.camp)
	return _os_
end

function SingleCharacterBasic:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.level = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	self.school = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.position:unmarshal(_os_)

	self.camp = _os_:unmarshal_char()
	return _os_
end

return SingleCharacterBasic
