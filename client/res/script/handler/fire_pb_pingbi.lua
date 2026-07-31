local sblackroles = require "protodef.fire.pb.pingbi.sblackroles"
function sblackroles:process()
	if BanListManager.getInstance() then
		BanListManager.getInstance():RefreshBanList(self.blackroles)
	end
	if FriendDialog.getInstanceNotCreate() then
		FriendDialog.getInstance():freshContactsByType(3)
	end
end

local ssearchblackroleinfo = require "protodef.fire.pb.pingbi.ssearchblackroleinfo"
function ssearchblackroleinfo:process()
	require "logic.friend.frienddialog"
	if FriendDialog.getInstanceNotCreate() then
		FriendDialog.getInstanceNotCreate():InitBlackSearchList(self.searchblackrole)
	end
end
