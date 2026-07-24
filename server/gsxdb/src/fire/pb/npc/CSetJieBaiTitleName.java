//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.item.Pack;
import fire.pb.mission.instance.InstanceManager;
import fire.pb.scene.manager.RoleManager;
import fire.pb.scene.movable.Role;
import fire.pb.scene.movable.SceneTeam;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.CheckName;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import mkdb.Procedure;
import xbean.Pod;
import xbean.jiebaiAskInfo;
import xtable.Jiebaiinfos;
import xtable.Locks;

public class CSetJieBaiTitleName extends __CSetJieBaiTitleName__ {
    public static final int PROTOCOL_TYPE = 817946;
    public static final int NAMELEN_MAX = 6;
    public static final int NAMELEN_MIN = 1;
    public String jiebaititlename;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            final Role role = RoleManager.getInstance().getRoleByProtocol(this);
            if (role != null) {
                SceneTeam team = role.getTeam();
                if (team != null && team.getAllTeammates().size() >= 3) {
                    int resultCode = CheckName.checkValid(this.jiebaititlename);
                    if (resultCode == -3) {
                        MessageMgr.sendMsgNotify(roleid, 142260, (List)null);
                    } else if (resultCode == -1) {
                        MessageMgr.sendMsgNotify(roleid, 142294, (List)null);
                    } else if (resultCode == -2) {
                        MessageMgr.sendMsgNotify(roleid, 146238, (List)null);
                    } else {
                        Procedure askIntoInst = new Procedure() {
                            protected boolean process() {
                                SceneTeam team1 = role.getTeam();
                                if (team1 != null) {
                                    final Team team = TeamManager.getTeamByTeamID(team1.getTeamID());
                                    if (team == null) {
                                        return false;
                                    }

                                    ArrayList<Long> roleids = new ArrayList();
                                    roleids.addAll(team.getNormalMemberIds());
                                    ArrayList<String> strings1 = new ArrayList();
                                    Iterator var5 = roleids.iterator();

                                    PropRole propRole;
                                    while(var5.hasNext()) {
                                        Long roleidx = (Long)var5.next();
                                        Pack itemBases = new Pack(roleidx, false);
                                        int bagItemNum = itemBases.getBagItemNum(420516);
                                        propRole = new PropRole(roleidx, false);
                                        if (bagItemNum < 1) {
                                            strings1.add(propRole.getName());
                                        }
                                    }

                                    Iterator var15;
                                    if (!strings1.isEmpty()) {
                                        ArrayList<String> rolename = new ArrayList();
                                        if (strings1.size() > 1) {
                                            String rName = "";

                                            String s;
                                            for(var15 = strings1.iterator(); var15.hasNext(); rName = rName + s + "??") {
                                                s = (String)var15.next();
                                            }

                                            rolename.add(rName);
                                        } else {
                                            rolename = strings1;
                                        }

                                        MessageMgr.sendMsgNotify(roleid, 191217, rolename);
                                        return false;
                                    }

                                    List<Role> allTeammates1 = team1.getAllTeammates();
                                    ArrayList<String> strings = new ArrayList();
                                    var15 = allTeammates1.iterator();

                                    while(var15.hasNext()) {
                                        Role role1 = (Role)var15.next();
                                        propRole = new PropRole(role1.getRoleID(), false);
                                        if (!propRole.getjblb().isEmpty()) {
                                            strings.add(propRole.getName());
                                            MessageMgr.sendMsgNotify(roleid, 191208, strings);
                                            return false;
                                        }
                                    }

                                    System.out.println("???????id" + team1.getTeamID());
                                    jiebaiAskInfo jiebaiAskInfo = Jiebaiinfos.get(team1.getTeamID());
                                    if (jiebaiAskInfo == null) {
                                        jiebaiAskInfo = Pod.newjiebaiAskInfo();
                                        jiebaiAskInfo.setTitlename(CSetJieBaiTitleName.this.jiebaititlename);
                                        Jiebaiinfos.insert(team1.getTeamID(), jiebaiAskInfo);
                                    } else {
                                        List<Role> allTeammates = team1.getAllTeammates();
                                        Iterator<Long> iterator = jiebaiAskInfo.getJiebaiinfo().keySet().iterator();

                                        while(iterator.hasNext()) {
                                            Long next = (Long)iterator.next();
                                            if (allTeammates.contains(next)) {
                                                iterator.remove();
                                            }
                                        }

                                        jiebaiAskInfo.setTitlename(CSetJieBaiTitleName.this.jiebaititlename);
                                    }

                                    Iterator var19 = roleids.iterator();

                                    while(var19.hasNext()) {
                                        Long rid = (Long)var19.next();
                                        jiebaiAskInfo.getJiebaiinfo().put(rid, "");
                                    }

                                    this.lock(xtable.Locks.ROLELOCK, roleids);
                                    SJieBaiInfo sJieBaiInfo = new SJieBaiInfo();
                                    sJieBaiInfo.titlename = CSetJieBaiTitleName.this.jiebaititlename;
                                    sJieBaiInfo.teamid = team1.getTeamID();
                                    Procedure.psendWhileCommit(roleids, sJieBaiInfo);
                                    ScheduledFuture<?> future = Executor.getInstance().schedule(new Runnable() {
                                        public void run() {
                                            (new Procedure() {
                                                protected boolean process() throws Exception {
                                                    Jiebaiinfos.remove(team.getTeamId());
                                                    return true;
                                                }
                                            }).submit();
                                        }
                                    }, 120L, TimeUnit.SECONDS);
                                    InstanceManager.askInstFuture.put(team.getTeamId(), future);
                                }

                                return true;
                            }
                        };
                        askIntoInst.submit();
                    }
                } else {
                    MessageMgr.sendMsgNotify(roleid, 191206, (List)null);
                }
            }
        }
    }

    public int getType() {
        return 817946;
    }

    public CSetJieBaiTitleName() {
        this.jiebaititlename = "";
    }

    public CSetJieBaiTitleName(String _jiebaititlename_) {
        this.jiebaititlename = _jiebaititlename_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.jiebaititlename, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.jiebaititlename = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSetJieBaiTitleName) {
            CSetJieBaiTitleName _o_ = (CSetJieBaiTitleName)_o1_;
            return this.jiebaititlename.equals(_o_.jiebaititlename);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.jiebaititlename.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.jiebaititlename.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
