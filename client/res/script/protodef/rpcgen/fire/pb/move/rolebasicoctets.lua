require "utils.tableutil"
RoleBasicOctets = {
	SHOW_PET = 1,
	TEAM_INFO = 2,
	TITLE_ID = 3,
	TITLE_NAME = 4,
	STALL_NAME = 5,
	MODEL_TEMPLATE = 6,
	HEADRESS_SHAPE = 7,
	SCENE_STATE = 8,
	WEAPON_BASEID = 9,
	WEAPON_COLOR = 10,
	ROLE_ACTUALLY_SHAPE = 12,
	PLAYING_ACTION = 13,
	STALL_BOARD = 14,
	FOOT_LOGO_ID = 15,
	AWAKE_STATE = 16,
	FOLLOW_NPC = 17,
	CRUISE = 18,
	EFFECT_EQUIP = 19,
	CRUISE2 = 20,
	CRUISE3 = 21
}
RoleBasicOctets.__index = RoleBasicOctets


function RoleBasicOctets:new()
	local self = {}
	setmetatable(self, RoleBasicOctets)
	self.roleid = 0
	self.rolename = "" 
	self.dirandschool = 0
	self.shape = 0
	self.level = 0
	self.camp = 0
	self.components = {}
	self.datas = {}

	return self
end
function RoleBasicOctets:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_char(self.dirandschool)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)
	_os_:marshal_char(self.camp)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_char(k)
		_os_: marshal_octets(v)
	end

	return _os_
end

function RoleBasicOctets:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.dirandschool = _os_:unmarshal_char()
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_char()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = FireNet.Octets()
		_os_:unmarshal_octets(newvalue)
		self.datas[newkey] = newvalue
	end
	return _os_
end

return RoleBasicOctets
