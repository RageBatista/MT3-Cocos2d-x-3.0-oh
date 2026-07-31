require "utils.tableutil"
CLiveSkillMakeDrug = {}
CLiveSkillMakeDrug.__index = CLiveSkillMakeDrug



CLiveSkillMakeDrug.PROTOCOL_TYPE = 800519

function CLiveSkillMakeDrug.Create()
	print("enter CLiveSkillMakeDrug create")
	return CLiveSkillMakeDrug:new()
end
function CLiveSkillMakeDrug:new()
	local self = {}
	setmetatable(self, CLiveSkillMakeDrug)
	self.type = self.PROTOCOL_TYPE
	self.makingslist = {}

	return self
end
function CLiveSkillMakeDrug:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveSkillMakeDrug:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.makingslist))
	for k,v in ipairs(self.makingslist) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CLiveSkillMakeDrug:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_makingslist=0 ,_os_null_makingslist
	_os_null_makingslist, sizeof_makingslist = _os_: uncompact_uint32(sizeof_makingslist)
	for k = 1,sizeof_makingslist do
		self.makingslist[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CLiveSkillMakeDrug
