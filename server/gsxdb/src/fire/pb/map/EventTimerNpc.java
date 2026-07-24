//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;
import mytools.ConvMain;

public class EventTimerNpc implements ConvMain.Checkable {
    public int id = 0;
    public int refreshGroup = 0;
    public int levelMin = 0;
    public int levelMax = 0;
    public int messageId = 0;
    public String npcList = null;
    public int npcGroupCount = 0;
    public int npcCount = 0;
    public int freshControl = 0;
    public int npcAllCount = 0;
    public String sceneList = null;
    public int sceneCnt = 0;
    public int npcLastTime = 0;
    public int awardOverStepNotice = 0;
    public int awardCnt = 0;
    public int awardId = 0;
    public int awardId2 = 0;
    public int teamRequire = 0;
    public int teamCount = 0;
    public int teamLevelMin = 0;
    public int teamLevelMax = 0;
    public int matchtype = 0;
    public String awardids = null;
    public int battletime = 0;
    public int canwatchbattle = 0;
    public int xiaoshi = 0;
    public int actid = 0;
    public int matchtime = 0;
    public int match = 0;
    public int havetimes = 0;
    public String leveltimes = null;
    public int delaysec = 0;
    public int delaynoticeid = 0;

    public EventTimerNpc() {
    }

    public EventTimerNpc(EventTimerNpc arg) {
        this.id = arg.id;
        this.refreshGroup = arg.refreshGroup;
        this.levelMin = arg.levelMin;
        this.levelMax = arg.levelMax;
        this.messageId = arg.messageId;
        this.npcList = arg.npcList;
        this.npcGroupCount = arg.npcGroupCount;
        this.npcCount = arg.npcCount;
        this.freshControl = arg.freshControl;
        this.npcAllCount = arg.npcAllCount;
        this.sceneList = arg.sceneList;
        this.sceneCnt = arg.sceneCnt;
        this.npcLastTime = arg.npcLastTime;
        this.awardOverStepNotice = arg.awardOverStepNotice;
        this.awardCnt = arg.awardCnt;
        this.awardId = arg.awardId;
        this.awardId2 = arg.awardId2;
        this.teamRequire = arg.teamRequire;
        this.teamCount = arg.teamCount;
        this.teamLevelMin = arg.teamLevelMin;
        this.teamLevelMax = arg.teamLevelMax;
        this.matchtype = arg.matchtype;
        this.awardids = arg.awardids;
        this.battletime = arg.battletime;
        this.canwatchbattle = arg.canwatchbattle;
        this.xiaoshi = arg.xiaoshi;
        this.actid = arg.actid;
        this.matchtime = arg.matchtime;
        this.match = arg.match;
        this.havetimes = arg.havetimes;
        this.leveltimes = arg.leveltimes;
        this.delaysec = arg.delaysec;
        this.delaynoticeid = arg.delaynoticeid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getRefreshGroup() {
        return this.refreshGroup;
    }

    public void setRefreshGroup(int v) {
        this.refreshGroup = v;
    }

    public int getLevelMin() {
        return this.levelMin;
    }

    public void setLevelMin(int v) {
        this.levelMin = v;
    }

    public int getLevelMax() {
        return this.levelMax;
    }

    public void setLevelMax(int v) {
        this.levelMax = v;
    }

    public int getMessageId() {
        return this.messageId;
    }

    public void setMessageId(int v) {
        this.messageId = v;
    }

    public String getNpcList() {
        return this.npcList;
    }

    public void setNpcList(String v) {
        this.npcList = v;
    }

    public int getNpcGroupCount() {
        return this.npcGroupCount;
    }

    public void setNpcGroupCount(int v) {
        this.npcGroupCount = v;
    }

    public int getNpcCount() {
        return this.npcCount;
    }

    public void setNpcCount(int v) {
        this.npcCount = v;
    }

    public int getFreshControl() {
        return this.freshControl;
    }

    public void setFreshControl(int v) {
        this.freshControl = v;
    }

    public int getNpcAllCount() {
        return this.npcAllCount;
    }

    public void setNpcAllCount(int v) {
        this.npcAllCount = v;
    }

    public String getSceneList() {
        return this.sceneList;
    }

    public void setSceneList(String v) {
        this.sceneList = v;
    }

    public int getSceneCnt() {
        return this.sceneCnt;
    }

    public void setSceneCnt(int v) {
        this.sceneCnt = v;
    }

    public int getNpcLastTime() {
        return this.npcLastTime;
    }

    public void setNpcLastTime(int v) {
        this.npcLastTime = v;
    }

    public int getAwardOverStepNotice() {
        return this.awardOverStepNotice;
    }

    public void setAwardOverStepNotice(int v) {
        this.awardOverStepNotice = v;
    }

    public int getAwardCnt() {
        return this.awardCnt;
    }

    public void setAwardCnt(int v) {
        this.awardCnt = v;
    }

    public int getAwardId() {
        return this.awardId;
    }

    public void setAwardId(int v) {
        this.awardId = v;
    }

    public int getAwardId2() {
        return this.awardId2;
    }

    public void setAwardId2(int v) {
        this.awardId2 = v;
    }

    public int getTeamRequire() {
        return this.teamRequire;
    }

    public void setTeamRequire(int v) {
        this.teamRequire = v;
    }

    public int getTeamCount() {
        return this.teamCount;
    }

    public void setTeamCount(int v) {
        this.teamCount = v;
    }

    public int getTeamLevelMin() {
        return this.teamLevelMin;
    }

    public void setTeamLevelMin(int v) {
        this.teamLevelMin = v;
    }

    public int getTeamLevelMax() {
        return this.teamLevelMax;
    }

    public void setTeamLevelMax(int v) {
        this.teamLevelMax = v;
    }

    public int getMatchtype() {
        return this.matchtype;
    }

    public void setMatchtype(int v) {
        this.matchtype = v;
    }

    public String getAwardids() {
        return this.awardids;
    }

    public void setAwardids(String v) {
        this.awardids = v;
    }

    public int getBattletime() {
        return this.battletime;
    }

    public void setBattletime(int v) {
        this.battletime = v;
    }

    public int getCanwatchbattle() {
        return this.canwatchbattle;
    }

    public void setCanwatchbattle(int v) {
        this.canwatchbattle = v;
    }

    public int getXiaoshi() {
        return this.xiaoshi;
    }

    public void setXiaoshi(int v) {
        this.xiaoshi = v;
    }

    public int getActid() {
        return this.actid;
    }

    public void setActid(int v) {
        this.actid = v;
    }

    public int getMatchtime() {
        return this.matchtime;
    }

    public void setMatchtime(int v) {
        this.matchtime = v;
    }

    public int getMatch() {
        return this.match;
    }

    public void setMatch(int v) {
        this.match = v;
    }

    public int getHavetimes() {
        return this.havetimes;
    }

    public void setHavetimes(int v) {
        this.havetimes = v;
    }

    public String getLeveltimes() {
        return this.leveltimes;
    }

    public void setLeveltimes(String v) {
        this.leveltimes = v;
    }

    public int getDelaysec() {
        return this.delaysec;
    }

    public void setDelaysec(int v) {
        this.delaysec = v;
    }

    public int getDelaynoticeid() {
        return this.delaynoticeid;
    }

    public void setDelaynoticeid(int v) {
        this.delaynoticeid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
