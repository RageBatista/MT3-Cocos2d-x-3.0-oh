
local spaceprotocol_getCommentList = {}


function spaceprotocol_getCommentList.request(nStateId,nPreId,nSpaceType)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.getCommentList
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..tostring(nStateId) --2
    strProtocolParam = strProtocolParam..","..tostring(nPreId) --3
    strProtocolParam = strProtocolParam..","..tostring(nSpaceType) --4

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local strServerId = Spaceprotocol.getServerId()

    local strData = "serverkey="..strServerId
    strData = strData.."&status_id="..nStateId
    strData = strData.."&status_comment_id="..nPreId

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--c json
function spaceprotocol_getCommentList.process(strData,vstrParam)
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    local nArrayNum = pJson_data.size
    if nArrayNum==0 then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    --id,nPreId
    if #vstrParam <4 then
        return
    end
    local nStateId = tonumber(vstrParam[2]) 
    local nPreId = tonumber(vstrParam[3]) 
    local nSpaceType = tonumber(vstrParam[4]) 
    
    --[[
    local MapRoot = json.decode(strData)
    local vRoleDataServer = MapRoot.data
    if not vRoleDataServer  then
        return
    end
    
    local nNum =  require("utils.tableutil").tablelength(vRoleDataServer)
    if nNum==0 then
        return
    end
    --]]
    
    local Spacemanager = require("logic.space.spacemanager")
    local spManager = Spacemanager.getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()


     local Spacedialog = require("logic.space.spacedialog")
     local vState = nil
     if nSpaceType==Spacedialog.eSpaceType.friendAround then
            vState = spManager.vFriendSay
     elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
     elseif nSpaceType==Spacedialog.eSpaceType.mySay then
            vState = spManager.vMySayState
     end

      local oneStateData = getSpaceManager():getOneStateData(vState,nStateId)
      if not oneStateData then
          gGetSpaceManager():SpaceJson_dispose(pJson_root)
          return 
      end

    if nPreId==0 then
         oneStateData.vSayToRole = {}
    end

    local pJson_array = pJson_data 
    local pJson_oneComment = pJson_array.child
    for nIndex=1,nArrayNum  do
        local oneComment = {}
        Spaceprotocol.readOneComment(oneComment,pJson_oneComment)
        pJson_oneComment = pJson_oneComment.next
        table.insert(oneStateData.vSayToRole,oneComment)
    end
    --------
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    
    if nPreId==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadCommentList)
    else
        eventManager:pushCmd(Eventmanager.eCmd.refreshCommentListDownNextPage)
    end

    --local Spacemanager = require("logic.space.spacemanager")
    --spManager:updateListRoleLevel(Spacemanager.eListType.friendState)

end



return spaceprotocol_getCommentList