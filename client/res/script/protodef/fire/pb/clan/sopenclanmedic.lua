require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.medicitem"
SOpenClanMedic = {}
SOpenClanMedic.__index = SOpenClanMedic



SOpenClanMedic.PROTOCOL_TYPE = 808440

function SOpenClanMedic.Create()
	print("enter SOpenClanMedic create")
	return SOpenClanMedic:new()
end
function SOpenClanMedic:new()
	local self = {}
	setmetatable(self, SOpenClanMedic)
	self.type = self.PROTOCOL_TYPE
	self.selecttype = 0
	self.buyitemnum = 0
	self.medicitemlist = {}

	return self
end
function SOpenClanMedic:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenClanMedic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.selecttype)
	_os_:marshal_int32(self.buyitemnum)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.medicitemlist))
	for k,v in ipairs(self.medicitemlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SOpenClanMedic:unmarshal(_os_)
	self.selecttype = _os_:unmarshal_int32()
	self.buyitemnum = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_medicitemlist=0,_os_null_medicitemlist
	_os_null_medicitemlist, sizeof_medicitemlist = _os_: uncompact_uint32(sizeof_medicitemlist)
	for k = 1,sizeof_medicitemlist do
		----------------unmarshal bean
		self.medicitemlist[k]=MedicItem:new()

		self.medicitemlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SOpenClanMedic
