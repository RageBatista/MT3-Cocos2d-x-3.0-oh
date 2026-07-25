require "utils.tableutil"
SRefreshRoleScore = {
	TOTAL_SCORE = 1,
	EQUIP_SCORE = 2,
	MANY_PET_SCORE = 3,
	PET_SCORE = 4,
	LEVEL_SCORE = 5,
	XIULIAN_SCORE = 6,
	ROLE_SCORE = 7,
	SKILL_SCORE = 8
}
SRefreshRoleScore.__index = SRefreshRoleScore



SRefreshRoleScore.PROTOCOL_TYPE = 799436

function SRefreshRoleScore.Create()
	print("enter SRefreshRoleScore create")
	return SRefreshRoleScore:new()
end
function SRefreshRoleScore:new()
	local self = {}
	setmetatable(self, SRefreshRoleScore)
	self.type = self.PROTOCOL_TYPE
	self.datas = {}

	return self
end
function SRefreshRoleScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRefreshRoleScore:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SRefreshRoleScore
