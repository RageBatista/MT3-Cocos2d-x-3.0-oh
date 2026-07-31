
Eventmanager = {}
Eventmanager.__index = Eventmanager
local _instance = nil


Eventmanager.eCmd=
{
    refreshRoleInfoHttp=1,
    refreshRoleInfoGs=2,
    refreshFriendList=3,
    refreshMySayState=4,
    refreshLeftWord=5,
    refreshPopularityList=6,
    refreshReceiveGift=7,
    refreshClickLike=8,
    refreshAddComment=9,
    delComment = 10,
    setSign = 11,
    delBbs = 12,
    addPopular=13,
    refreshPopuInfo=14,
    showHeadPic=15,
    reloadFriendStateList=16,
    reloadMySayList =17,
    reloadLeftWord=18,
    refreshSpaceAddFriendBtn=19,
    reloadRecGift=20,
    refreshLeftWordDownNextPage=21,
    refreshLeftWordAddBbs=22,
    refreshMySayListDownNextPage=23,
    refreshFriendListDownNextPage=24,
    refreshReceiveGiftDownNextPage=25,
    reloadPopularityList=26,
    refreshPopularityListDownNextPage=27,
    giveGiftEnd=28,
    delState = 29,
    refreshLocation=30,
    refreshRoleLevel=31,
    delHeadResult=32,
    getPicResult=33,
    sendStateGetImageResult=34,
    liuyanResult = 35,
    commentFriendList=36,
    commentMyStateList=37,
    clearHeadPic=38,
    refreshNpcSpaceInfo=39,
    reloadNpcSpaceBbs=40,
    refreshNpcBbs_downNextPage=41,
    reloadCommentList = 42,
    refreshCommentListDownNextPage = 43,

}
--[[
Eventmanager.targetData=
{
    pTarget=nil,
    callBack=nil
}

Eventmanager.CmdData =
{
    cmdId =0,
    vTarget={} --targetData

}
--]]

function Eventmanager:new()
    local self = {}
    setmetatable(self, Eventmanager)
	self:clearData()
    return self
end

function Eventmanager:clearData()
	self.mapEvent = {}
end

function Eventmanager.Destroy()
    if _instance then 
		_instance:clearData()
        _instance = nil
    end
end


function Eventmanager.getInstance()
	if not _instance then
		_instance = Eventmanager:new()
	end
	return _instance
end


function Eventmanager:isHaveEvent(nCmd,pTarget,callBack)
    local cmdData = self.mapEvent[nCmd]
    if not cmdData then
        return false
    end
    local vTarget = cmdData.vTarget
    for nIndex=1,#vTarget do
        local oneTargetData = cmdData.vTarget[nIndex]
        if oneTargetData.pTarget==pTarget and oneTargetData.callBack==callBack then
            return true
        end
    end
    return false
end

function Eventmanager:addEvent(nCmd,pTarget,callBack)
    local cmdData = self.mapEvent[nCmd]
    if not cmdData then
        self.mapEvent[nCmd] = {}
        self.mapEvent[nCmd].cmdId = nCmd
        self.mapEvent[nCmd].vTarget = {}
        local vTarget = self.mapEvent[nCmd].vTarget
        vTarget[1] = {}
        vTarget[1].pTarget = pTarget
        vTarget[1].callBack = callBack
    else
        for nIndex=1,#cmdData.vTarget do
        local oneTargetData = cmdData.vTarget[nIndex]
            if oneTargetData.pTarget==pTarget and oneTargetData.callBack==callBack then
                return 
            end
        end
        cmdData.vTarget[#cmdData.vTarget +1] = {}
        cmdData.vTarget[#cmdData.vTarget].pTarget = pTarget
        cmdData.vTarget[#cmdData.vTarget].callBack =callBack
    end
end

function Eventmanager:removeEvent(nCmdId,pTarget,callBack)
    local cmdData = self.mapEvent[nCmdId]
    if not cmdData then
        return
    else
        for nIndex=1,#cmdData.vTarget do
            local oneTargetData = cmdData.vTarget[nIndex]
            if oneTargetData.pTarget==pTarget and oneTargetData.callBack==callBack then
                table.remove(cmdData.vTarget,nIndex)
                return 
            end
        end
    end
end

function Eventmanager:pushCmd(nCmdId,vstrParam)
    local cmdData = self.mapEvent[nCmdId]
    if not cmdData then
        return
    end

    for nIndex=1,#cmdData.vTarget do
        local oneTargetData = cmdData.vTarget[nIndex]
        if oneTargetData.pTarget and oneTargetData.callBack then
              oneTargetData.callBack(oneTargetData.pTarget,vstrParam)
        end
    end
    
end

return Eventmanager
