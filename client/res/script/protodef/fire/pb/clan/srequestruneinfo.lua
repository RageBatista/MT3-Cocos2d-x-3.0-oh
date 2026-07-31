require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.runeinfo"
SRequestRuneInfo = {}
SRequestRuneInfo.__index = SRequestRuneInfo



SRequestRuneInfo.PROTOCOL_TYPE = 808508

function SRequestRuneInfo.Create()
	print("enter SRequestRuneInfo create")
	return SRequestRuneInfo:new()
end
function SRequestRuneInfo:new()
	local self = {}
	setmetatable(self, SRequestRuneInfo)
	self.type = self.PROTOCOL_TYPE
	self.requestnum = 0
	self.useenergy = 0
	self.runeinfolist = {}

	return self
end
function SRequestRuneInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestRuneInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.requestnum)
	_os_:marshal_int32(self.useenergy)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.runeinfolist))
	for k,v in ipairs(self.runeinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestRuneInfo:unmarshal(_os_)
	self.requestnum = _os_:unmarshal_int32()
	self.useenergy = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_runeinfolist=0,_os_null_runeinfolist
	_os_null_runeinfolist, sizeof_runeinfolist = _os_: uncompact_uint32(sizeof_runeinfolist)
	for k = 1,sizeof_runeinfolist do
		----------------unmarshal bean
		self.runeinfolist[k]=RuneInfo:new()

		self.runeinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestRuneInfo
