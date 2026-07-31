require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.livedie.ldroleinfodes"
require "protodef.rpcgen.fire.pb.battle.livedie.ldroleinfowatchdes"
SLiveDieBattleWatchView = {}
SLiveDieBattleWatchView.__index = SLiveDieBattleWatchView



SLiveDieBattleWatchView.PROTOCOL_TYPE = 793841

function SLiveDieBattleWatchView.Create()
	print("enter SLiveDieBattleWatchView create")
	return SLiveDieBattleWatchView:new()
end
function SLiveDieBattleWatchView:new()
	local self = {}
	setmetatable(self, SLiveDieBattleWatchView)
	self.type = self.PROTOCOL_TYPE
	self.rolewatchlist = {}

	return self
end
function SLiveDieBattleWatchView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveDieBattleWatchView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rolewatchlist))
	for k,v in ipairs(self.rolewatchlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SLiveDieBattleWatchView:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_rolewatchlist=0,_os_null_rolewatchlist
	_os_null_rolewatchlist, sizeof_rolewatchlist = _os_: uncompact_uint32(sizeof_rolewatchlist)
	for k = 1,sizeof_rolewatchlist do
		----------------unmarshal bean
		self.rolewatchlist[k]=LDRoleInfoWatchDes:new()

		self.rolewatchlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SLiveDieBattleWatchView
