require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.redpack.redpackroletip"
SNoticeRedPackList = {}
SNoticeRedPackList.__index = SNoticeRedPackList



SNoticeRedPackList.PROTOCOL_TYPE = 812543

function SNoticeRedPackList.Create()
	print("enter SNoticeRedPackList create")
	return SNoticeRedPackList:new()
end
function SNoticeRedPackList:new()
	local self = {}
	setmetatable(self, SNoticeRedPackList)
	self.type = self.PROTOCOL_TYPE
	self.redpackroletiplist = {}

	return self
end
function SNoticeRedPackList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNoticeRedPackList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.redpackroletiplist))
	for k,v in ipairs(self.redpackroletiplist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SNoticeRedPackList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_redpackroletiplist=0,_os_null_redpackroletiplist
	_os_null_redpackroletiplist, sizeof_redpackroletiplist = _os_: uncompact_uint32(sizeof_redpackroletiplist)
	for k = 1,sizeof_redpackroletiplist do
		----------------unmarshal bean
		self.redpackroletiplist[k]=RedPackRoleTip:new()

		self.redpackroletiplist[k]:unmarshal(_os_)

	end
	return _os_
end

return SNoticeRedPackList
