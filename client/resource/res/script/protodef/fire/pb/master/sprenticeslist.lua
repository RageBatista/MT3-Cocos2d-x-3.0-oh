require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.achive"
require "protodef.rpcgen.fire.pb.master.pbaseinfo"
require "protodef.rpcgen.fire.pb.master.pinfo"
SPrenticesList = {}
SPrenticesList.__index = SPrenticesList



SPrenticesList.PROTOCOL_TYPE = 816481

function SPrenticesList.Create()
	print("enter SPrenticesList create")
	return SPrenticesList:new()
end
function SPrenticesList:new()
	local self = {}
	setmetatable(self, SPrenticesList)
	self.type = self.PROTOCOL_TYPE
	self.prenticelist = {}
	self.chushilist = {}
	self.shide = 0

	return self
end
function SPrenticesList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPrenticesList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prenticelist))
	for k,v in ipairs(self.prenticelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.chushilist))
	for k,v in ipairs(self.chushilist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int64(self.shide)
	return _os_
end

function SPrenticesList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_prenticelist=0,_os_null_prenticelist
	_os_null_prenticelist, sizeof_prenticelist = _os_: uncompact_uint32(sizeof_prenticelist)
	for k = 1,sizeof_prenticelist do
		----------------unmarshal bean
		self.prenticelist[k]=PInfo:new()

		self.prenticelist[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_chushilist=0,_os_null_chushilist
	_os_null_chushilist, sizeof_chushilist = _os_: uncompact_uint32(sizeof_chushilist)
	for k = 1,sizeof_chushilist do
		----------------unmarshal bean
		self.chushilist[k]=PBaseInfo:new()

		self.chushilist[k]:unmarshal(_os_)

	end
	self.shide = _os_:unmarshal_int64()
	return _os_
end

return SPrenticesList
