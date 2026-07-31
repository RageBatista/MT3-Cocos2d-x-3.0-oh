require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.clanmember"
SOpenClan = {}
SOpenClan.__index = SOpenClan



SOpenClan.PROTOCOL_TYPE = 808449

function SOpenClan.Create()
	print("enter SOpenClan create")
	return SOpenClan:new()
end
function SOpenClan:new()
	local self = {}
	setmetatable(self, SOpenClan)
	self.type = self.PROTOCOL_TYPE
	self.index = 0
	self.clanname = "" 
	self.clanid = 0
	self.clanlevel = 0
	self.membersnum = 0
	self.clanmaster = "" 
	self.masterid = 0
	self.vicemasterid = 0
	self.clancreator = "" 
	self.clanaim = "" 
	self.memberlist = {}
	self.money = 0
	self.house = {}
	self.oldclanname = "" 
	self.clancreatorid = 0
	self.autostate = 0
	self.requestlevel = 0
	self.costeverymoney = 0
	self.costmax = {}
	self.claninstservice = {}

	return self
end
function SOpenClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.index)
	_os_:marshal_wstring(self.clanname)
	_os_:marshal_int64(self.clanid)
	_os_:marshal_int32(self.clanlevel)
	_os_:marshal_int32(self.membersnum)
	_os_:marshal_wstring(self.clanmaster)
	_os_:marshal_int64(self.masterid)
	_os_:marshal_int64(self.vicemasterid)
	_os_:marshal_wstring(self.clancreator)
	_os_:marshal_wstring(self.clanaim)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.money)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.house))
	for k,v in pairs(self.house) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_wstring(self.oldclanname)
	_os_:marshal_int64(self.clancreatorid)
	_os_:marshal_int32(self.autostate)
	_os_:marshal_short(self.requestlevel)
	_os_:marshal_int32(self.costeverymoney)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.costmax))
	for k,v in pairs(self.costmax) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.claninstservice))
	for k,v in pairs(self.claninstservice) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SOpenClan:unmarshal(_os_)
	self.index = _os_:unmarshal_int32()
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	self.clanid = _os_:unmarshal_int64()
	self.clanlevel = _os_:unmarshal_int32()
	self.membersnum = _os_:unmarshal_int32()
	self.clanmaster = _os_:unmarshal_wstring(self.clanmaster)
	self.masterid = _os_:unmarshal_int64()
	self.vicemasterid = _os_:unmarshal_int64()
	self.clancreator = _os_:unmarshal_wstring(self.clancreator)
	self.clanaim = _os_:unmarshal_wstring(self.clanaim)
	----------------unmarshal vector
	local sizeof_memberlist=0,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=ClanMember:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	self.money = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_house=0,_os_null_house
	_os_null_house, sizeof_house = _os_: uncompact_uint32(sizeof_house)
	for k = 1,sizeof_house do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.house[newkey] = newvalue
	end
	self.oldclanname = _os_:unmarshal_wstring(self.oldclanname)
	self.clancreatorid = _os_:unmarshal_int64()
	self.autostate = _os_:unmarshal_int32()
	self.requestlevel = _os_:unmarshal_short()
	self.costeverymoney = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_costmax=0,_os_null_costmax
	_os_null_costmax, sizeof_costmax = _os_: uncompact_uint32(sizeof_costmax)
	for k = 1,sizeof_costmax do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.costmax[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_claninstservice=0,_os_null_claninstservice
	_os_null_claninstservice, sizeof_claninstservice = _os_: uncompact_uint32(sizeof_claninstservice)
	for k = 1,sizeof_claninstservice do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.claninstservice[newkey] = newvalue
	end
	return _os_
end

return SOpenClan
