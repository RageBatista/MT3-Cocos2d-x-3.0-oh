//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.common.SCommon;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.scene.manager.RoleManager;
import fire.pb.scene.movable.Role;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.title.Title;
import fire.pb.util.BagUtil;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.jiebaiAskInfo;
import xtable.Jiebaiinfos;

public class CJieBaiQueRen extends __CJieBaiQueRen__ {
    public static final int PROTOCOL_TYPE = 817949;
    public String titlename;
    public long teamid;
    public int answer;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            final Role role = RoleManager.getInstance().getRoleByProtocol(this);
            if (role != null) {
                Procedure procedure = new Procedure() {
                    protected boolean process() {
                        if (CJieBaiQueRen.this.answer == 2) {
                            jiebaiAskInfo select = Jiebaiinfos.select(role.getTeamID());
                            if (select != null) {
                                Jiebaiinfos.remove(CJieBaiQueRen.this.teamid);
                            }

                            PropRole propRole = new PropRole(roleid, false);
                            Team team = TeamManager.getTeamByTeamID(role.getTeamID());
                            if (team == null) {
                                return false;
                            }

                            ArrayList<Long> roleids = new ArrayList();
                            roleids.addAll(team.getNormalMemberIds());
                            SJuJueJieBai sJuJueJieBai = new SJuJueJieBai();
                            Procedure.psendWhileCommit(roleids, sJuJueJieBai);
                            MessageMgr.psendMsgNotify(roleids, 191210, 0,Arrays.<String>asList(propRole.getName()));
                        }

                        if (CJieBaiQueRen.this.answer == 1) {
                            Team teamx = TeamManager.getTeamByTeamID(role.getTeamID());
                            if (teamx == null) {
                                return false;
                            }

                            ArrayList<Long> roleidsx = new ArrayList();
                            roleidsx.addAll(teamx.getNormalMemberIds());
                            jiebaiAskInfo jiebaiAskInfo = Jiebaiinfos.get(role.getTeamID());
                            if (jiebaiAskInfo == null) {
                                MessageMgr.psendMsgNotify(roleidsx, 191212, 0, (List)null);
                                return false;
                            }

                            Map<Long, String> jiebaiinfo = jiebaiAskInfo.getJiebaiinfo();
                            Iterator var23 = jiebaiinfo.keySet().iterator();

                            String name;
                            while(var23.hasNext()) {
                                Long aLong = (Long)var23.next();
                                name = (String)jiebaiinfo.get(aLong);
                                if (name == CJieBaiQueRen.this.titlename) {
                                    MessageMgr.sendMsgNotify(roleid, 191211, (List)null);
                                    return false;
                                }
                            }

                            jiebaiinfo.put(roleid, CJieBaiQueRen.this.titlename);
                            System.out.println("角色id：" + roleid + "称谓" + CJieBaiQueRen.this.titlename);
                            STongYiJieBai sTongYiJieBai = new STongYiJieBai();
                            sTongYiJieBai.titlename = CJieBaiQueRen.this.titlename;
                            sTongYiJieBai.roleid = roleid;
                            sTongYiJieBai.answer = CJieBaiQueRen.this.answer;
                            Procedure.psendWhileCommit(roleidsx, sTongYiJieBai);
                            int i = 0;
                            Iterator var26 = jiebaiinfo.keySet().iterator();

                            Long aLongx;
                            while(var26.hasNext()) {
                                aLongx = (Long)var26.next();
                                String s = (String)jiebaiinfo.get(aLongx);
                                if (s != "") {
                                    ++i;
                                }
                            }

                            if (i == jiebaiinfo.size()) {
                                var26 = roleidsx.iterator();

                                Pack itemBases;
                                while(var26.hasNext()) {
                                    aLongx = (Long)var26.next();
                                    itemBases = new Pack(aLongx, false);
                                    if (itemBases.getBagItemNum(420516) < 1) {
                                        return false;
                                    }
                                }

                                var26 = roleidsx.iterator();

                                while(var26.hasNext()) {
                                    aLongx = (Long)var26.next();
                                    itemBases = new Pack(aLongx, false);
                                    if (itemBases.removeItemById(420516, 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "结拜消耗") != 1) {
                                        System.out.println("结拜道具消耗失败！");
                                        return false;
                                    }
                                }

                                name = "";
                                System.out.println("全部队友同意了，进入结拜逻辑");
                                String titlename = jiebaiAskInfo.getTitlename();
                                SCommon conf = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(495);
                                Iterator var10 = roleidsx.iterator();

                                while(var10.hasNext()) {
                                    Long aLongxx = (Long)var10.next();
                                    Title title = new Title(aLongxx, false);
                                    PropRole propRolex = new PropRole(aLongxx, false);
                                    name = name + propRolex.getName() + ",";
                                    propRolex.setjblb(roleidsx);
                                    String sx = (String)jiebaiAskInfo.getJiebaiinfo().get(aLongxx);
                                    title.addTitle(213, titlename + sx, -1L);
                                    int itemid = 0;
                                    int itemnum = 0;
                                    if (conf != null) {
                                        String value = conf.getValue();
                                        String[] split = value.split(";");
                                        if (split.length < 2) {
                                            itemid = Integer.parseInt(split[0]);
                                            itemnum = Integer.parseInt(split[1]);
                                        }
                                    }

                                    if (itemid != 0 && itemnum != 0 && BagUtil.addItem(aLongxx, itemid, itemnum, "结拜赠送", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, itemid) != itemnum) {
                                        return false;
                                    }
                                }

                                SWanChengJieBai sWanChengJieBai = new SWanChengJieBai();
                                Procedure.psendWhileCommit(roleidsx, sWanChengJieBai);
                                ArrayList<String> strings = new ArrayList();
                                strings.add(name);
                                STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191216, 0, strings);
                                SceneManager.sendAll(ssmn);
                            }
                        }

                        return true;
                    }
                };
                procedure.submit();
            }
        }
    }

    public int getType() {
        return 817949;
    }

    public CJieBaiQueRen() {
        this.titlename = "";
    }

    public CJieBaiQueRen(String _titlename_, long _teamid_, int _answer_) {
        this.titlename = _titlename_;
        this.teamid = _teamid_;
        this.answer = _answer_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.titlename, "UTF-16LE");
            _os_.marshal(this.teamid);
            _os_.marshal(this.answer);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titlename = _os_.unmarshal_String("UTF-16LE");
        this.teamid = _os_.unmarshal_long();
        this.answer = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CJieBaiQueRen) {
            CJieBaiQueRen _o_ = (CJieBaiQueRen)_o1_;
            if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else if (this.teamid != _o_.teamid) {
                return false;
            } else {
                return this.answer == _o_.answer;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titlename.hashCode();
        _h_ += (int)this.teamid;
        _h_ += this.answer;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.teamid).append(",");
        _sb_.append(this.answer).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
