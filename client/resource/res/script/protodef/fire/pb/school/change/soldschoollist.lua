require "utils.tableutil"
SOldSchoolList = {}
SOldSchoolList.__index = SOldSchoolList



SOldSchoolList.PROTOCOL_TYPE = 810484

function SOldSchoolList.Create()
	print("enter SOldSchoolList create")
	return SOldSchoolList:new()
end
function SOldSchoolList:new()
	local self = {}
	setmetatable(self, SOldSchoolList)
	self.type = self.PROTOCOL_TYPE
	self.oldshapelist = {}
	self.oldschoollist = {}

	return self
end
function SOldSchoolList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOldSchoolList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.oldshapelist))
	for k,v in ipairs(self.oldshapelist) do
		_os_:marshal_int32(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.oldschoollist))
	for k,v in ipairs(self.oldschoollist) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SOldSchoolList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_oldshapelist=0,_os_null_oldshapelist
	_os_null_oldshapelist, sizeof_oldshapelist = _os_: uncompact_uint32(sizeof_oldshapelist)
	for k = 1,sizeof_oldshapelist do
		self.oldshapelist[k] = _os_:unmarshal_int32()
	end
	----------------unmarshal vector
	local sizeof_oldschoollist=0,_os_null_oldschoollist
	_os_null_oldschoollist, sizeof_oldschoollist = _os_: uncompact_uint32(sizeof_oldschoollist)
	for k = 1,sizeof_oldschoollist do
		self.oldschoollist[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SOldSchoolList
