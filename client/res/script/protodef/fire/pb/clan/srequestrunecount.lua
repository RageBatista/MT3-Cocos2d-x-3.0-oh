require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.runecountinfo"
SRequestRuneCount = {}
SRequestRuneCount.__index = SRequestRuneCount



SRequestRuneCount.PROTOCOL_TYPE = 808514

function SRequestRuneCount.Create()
	print("enter SRequestRuneCount create")
	return SRequestRuneCount:new()
end
function SRequestRuneCount:new()
	local self = {}
	setmetatable(self, SRequestRuneCount)
	self.type = self.PROTOCOL_TYPE
	self.runecountinfolist = {}

	return self
end
function SRequestRuneCount:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestRuneCount:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.runecountinfolist))
	for k,v in ipairs(self.runecountinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestRuneCount:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_runecountinfolist=0,_os_null_runecountinfolist
	_os_null_runecountinfolist, sizeof_runecountinfolist = _os_: uncompact_uint32(sizeof_runecountinfolist)
	for k = 1,sizeof_runecountinfolist do
		----------------unmarshal bean
		self.runecountinfolist[k]=RuneCountInfo:new()

		self.runecountinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestRuneCount
