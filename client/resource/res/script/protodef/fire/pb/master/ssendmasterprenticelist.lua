require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.rolebasedata"
SSendMasterPrenticeList = {}
SSendMasterPrenticeList.__index = SSendMasterPrenticeList



SSendMasterPrenticeList.PROTOCOL_TYPE = 816469

function SSendMasterPrenticeList.Create()
	print("enter SSendMasterPrenticeList create")
	return SSendMasterPrenticeList:new()
end
function SSendMasterPrenticeList:new()
	local self = {}
	setmetatable(self, SSendMasterPrenticeList)
	self.type = self.PROTOCOL_TYPE
	self.masterlist = {}
	self.prenticelist = {}

	return self
end
function SSendMasterPrenticeList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendMasterPrenticeList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.masterlist))
	for k,v in ipairs(self.masterlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prenticelist))
	for k,v in ipairs(self.prenticelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSendMasterPrenticeList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_masterlist=0,_os_null_masterlist
	_os_null_masterlist, sizeof_masterlist = _os_: uncompact_uint32(sizeof_masterlist)
	for k = 1,sizeof_masterlist do
		----------------unmarshal bean
		self.masterlist[k]=RoleBaseData:new()

		self.masterlist[k]:unmarshal(_os_)

	end
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

return SSendMasterPrenticeList
