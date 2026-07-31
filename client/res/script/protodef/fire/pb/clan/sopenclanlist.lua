require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.clansummaryinfo"
SOpenClanList = {}
SOpenClanList.__index = SOpenClanList



SOpenClanList.PROTOCOL_TYPE = 808448

function SOpenClanList.Create()
	print("enter SOpenClanList create")
	return SOpenClanList:new()
end
function SOpenClanList:new()
	local self = {}
	setmetatable(self, SOpenClanList)
	self.type = self.PROTOCOL_TYPE
	self.currpage = 0
	self.clanlist = {}

	return self
end
function SOpenClanList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenClanList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.currpage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.clanlist))
	for k,v in ipairs(self.clanlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SOpenClanList:unmarshal(_os_)
	self.currpage = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_clanlist=0,_os_null_clanlist
	_os_null_clanlist, sizeof_clanlist = _os_: uncompact_uint32(sizeof_clanlist)
	for k = 1,sizeof_clanlist do
		----------------unmarshal bean
		self.clanlist[k]=ClanSummaryInfo:new()

		self.clanlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SOpenClanList
