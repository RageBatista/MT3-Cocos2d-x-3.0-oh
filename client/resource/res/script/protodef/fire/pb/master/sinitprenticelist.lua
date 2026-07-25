require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.rolebasedata"
SInitPrenticeList = {}
SInitPrenticeList.__index = SInitPrenticeList



SInitPrenticeList.PROTOCOL_TYPE = 816461

function SInitPrenticeList.Create()
	print("enter SInitPrenticeList create")
	return SInitPrenticeList:new()
end
function SInitPrenticeList:new()
	local self = {}
	setmetatable(self, SInitPrenticeList)
	self.type = self.PROTOCOL_TYPE
	self.prenticelist = {}

	return self
end
function SInitPrenticeList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInitPrenticeList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prenticelist))
	for k,v in ipairs(self.prenticelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SInitPrenticeList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_prenticelist=0,_os_null_prenticelist
	_os_null_prenticelist, sizeof_prenticelist = _os_: uncompact_uint32(sizeof_prenticelist)
	for k = 1,sizeof_prenticelist do
		----------------unmarshal bean
		self.prenticelist[k]=RoleBaseData:new()

		self.prenticelist[k]:unmarshal(_os_)

	end
	return _os_
end

return SInitPrenticeList
