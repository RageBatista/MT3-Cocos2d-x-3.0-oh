require "utils.tableutil"
RoleBasicFightProperties = {}
RoleBasicFightProperties.__index = RoleBasicFightProperties


function RoleBasicFightProperties:new()
	local self = {}
	setmetatable(self, RoleBasicFightProperties)
	self.cons = 0
	self.iq = 0
	self.str = 0
	self.endu = 0
	self.agi = 0
	self.cons_save = {}
	self.iq_save = {}
	self.str_save = {}
	self.endu_save = {}
	self.agi_save = {}

	return self
end
function RoleBasicFightProperties:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.cons)
	_os_:marshal_short(self.iq)
	_os_:marshal_short(self.str)
	_os_:marshal_short(self.endu)
	_os_:marshal_short(self.agi)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.cons_save))
	for k,v in pairs(self.cons_save) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.iq_save))
	for k,v in pairs(self.iq_save) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.str_save))
	for k,v in pairs(self.str_save) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.endu_save))
	for k,v in pairs(self.endu_save) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.agi_save))
	for k,v in pairs(self.agi_save) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function RoleBasicFightProperties:unmarshal(_os_)
	self.cons = _os_:unmarshal_short()
	self.iq = _os_:unmarshal_short()
	self.str = _os_:unmarshal_short()
	self.endu = _os_:unmarshal_short()
	self.agi = _os_:unmarshal_short()
	----------------unmarshal map
	local sizeof_cons_save=0,_os_null_cons_save
	_os_null_cons_save, sizeof_cons_save = _os_: uncompact_uint32(sizeof_cons_save)
	for k = 1,sizeof_cons_save do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.cons_save[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_iq_save=0,_os_null_iq_save
	_os_null_iq_save, sizeof_iq_save = _os_: uncompact_uint32(sizeof_iq_save)
	for k = 1,sizeof_iq_save do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.iq_save[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_str_save=0,_os_null_str_save
	_os_null_str_save, sizeof_str_save = _os_: uncompact_uint32(sizeof_str_save)
	for k = 1,sizeof_str_save do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.str_save[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_endu_save=0,_os_null_endu_save
	_os_null_endu_save, sizeof_endu_save = _os_: uncompact_uint32(sizeof_endu_save)
	for k = 1,sizeof_endu_save do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.endu_save[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_agi_save=0,_os_null_agi_save
	_os_null_agi_save, sizeof_agi_save = _os_: uncompact_uint32(sizeof_agi_save)
	for k = 1,sizeof_agi_save do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.agi_save[newkey] = newvalue
	end
	return _os_
end

return RoleBasicFightProperties
