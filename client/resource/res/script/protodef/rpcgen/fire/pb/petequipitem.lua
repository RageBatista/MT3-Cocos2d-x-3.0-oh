require "utils.tableutil"
PetEquipItem = {}
PetEquipItem.__index = PetEquipItem


function PetEquipItem:new()
	local self = {}
	setmetatable(self, PetEquipItem)
	self.itemid = 0
	self.pos = 0
	self.pro = {}
	self.skills = {}

	return self
end
function PetEquipItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.pos)
	_os_:compact_uint32(TableUtil.tablelength(self.pro))
	for k,v in ipairs(self.pro) do
		----------------marshal bean
		v:marshal(_os_) 
	end
	_os_:compact_uint32(TableUtil.tablelength(self.skills))
	for k,v in ipairs(self.skills) do
		----------------marshal bean
		v:marshal(_os_) 
	end
	return _os_
end

function PetEquipItem:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.pos = _os_:unmarshal_int32()
	
	local sizeof_pro=0,_os_null_pro
	_os_null_pro, sizeof_pro = _os_: uncompact_uint32(sizeof_pro)
	for k = 1,sizeof_pro do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.pro[newkey] = newvalue
	end
	
	local sizeof_skill=0,_os_null_skill
	_os_null_skill, sizeof_skill = _os_: uncompact_uint32(sizeof_skill)
	for k = 1,sizeof_skill do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.skill[newkey] = newvalue
	end

	return _os_
end

return PetEquipItem
