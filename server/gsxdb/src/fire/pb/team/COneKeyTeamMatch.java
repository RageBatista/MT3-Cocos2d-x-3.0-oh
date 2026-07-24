//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.fushi.Module;
import fire.pb.main.ConfigManager;
import fire.pb.message.SStringRes;
import fire.pb.talk.ChatChannel;
import fire.pb.talk.DisplayInfo;
import fire.pb.talk.LastChatTime;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;
import xtable.Roleid2teamid;

public class COneKeyTeamMatch extends __COneKeyTeamMatch__ {
    public static final int PROTOCOL_TYPE = 794498;
    public int channeltype;
    public String text;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure onekeyteammatch = new Procedure() {
                protected boolean process() {
                    SOneKeyTeamMatch msg = new SOneKeyTeamMatch();
                    if (COneKeyTeamMatch.this.channeltype != 14 && COneKeyTeamMatch.this.channeltype != 5 && COneKeyTeamMatch.this.channeltype != 1 && COneKeyTeamMatch.this.channeltype != 4) {
                        msg.ret = 1;
                        Procedure.psendWhileCommit(roleid, msg);
                        return false;
                    } else {
                        if (COneKeyTeamMatch.this.channeltype == 4) {
                            Properties prop = xtable.Properties.select(roleid);
                            if (prop != null && prop.getClankey() <= 0L) {
                                MessageMgr.sendMsgNotify(roleid, 141053, (List)null);
                                msg.ret = 1;
                                Procedure.psendWhileCommit(roleid, msg);
                                return false;
                            }
                        }

                        Long teamid = Roleid2teamid.select(roleid);
                        if (teamid == null) {
                            psend(roleid, new STeamError(4));
                            TeamManager.logger.error("COneKeyTeamMatch:自己不是队长 " + roleid);
                            msg.ret = 1;
                            Procedure.psendWhileCommit(roleid, msg);
                            return true;
                        } else {
                            Team team = null;
                            team = TeamManager.getTeamByTeamID(teamid);
                            if (!team.isTeamLeader(roleid)) {
                                psend(roleid, new STeamError(4));
                                TeamManager.logger.error("COneKeyTeamMatch:自己不是队长 " + roleid);
                                msg.ret = 1;
                                Procedure.psendWhileCommit(roleid, msg);
                                return true;
                            } else {
                                teamid = Roleid2teamid.get(roleid);
                                if (Module.GetPayServiceType() == 1) {
                                    DSTeamMatchInfo config = (DSTeamMatchInfo)ConfigManager.getInstance().getConf(DSTeamMatchInfo.class).get(team.getTeamInfo().getTargetid());
                                    if (config == null) {
                                        psend(roleid, new STeamError(34));
                                        TeamManager.logger.error("COneKeyTeamMatch:目标ID错误 " + roleid);
                                        msg.ret = 1;
                                        Procedure.psendWhileCommit(roleid, msg);
                                        return true;
                                    }
                                } else {
                                    STeamMatchInfo config = (STeamMatchInfo)ConfigManager.getInstance().getConf(STeamMatchInfo.class).get(team.getTeamInfo().getTargetid());
                                    if (config == null) {
                                        psend(roleid, new STeamError(34));
                                        TeamManager.logger.error("COneKeyTeamMatch:目标ID错误 " + roleid);
                                        msg.ret = 1;
                                        Procedure.psendWhileCommit(roleid, msg);
                                        return true;
                                    }
                                }

                                long systemTime = System.currentTimeMillis();
                                long now = System.currentTimeMillis();
                                long delaytime = (long)ChatChannel.getInstance().getWorldChatDelayTime();
                                LastChatTime rctime = new LastChatTime(roleid, false);
                                if (COneKeyTeamMatch.this.channeltype == 5 && rctime.getLastWorldChatTime() + delaytime > now) {
                                    ArrayList<String> args = new ArrayList();
                                    args.add("" + (rctime.getLastWorldChatTime() + delaytime - now) / 1000L);
                                    MessageMgr.sendMsgNotify(roleid, 140500, args);
                                    msg.ret = 1;
                                    Procedure.psendWhileCommit(roleid, msg);
                                    return true;
                                } else {
                                    long delta = systemTime - team.getTeamInfo().getOnekeytimestamp() - 30000L;
                                    if (delta < 0L) {
                                        String s = String.format("%d", (int)(-delta) / 1000);
                                        MessageMgr.sendMsgNotify(roleid, 150028, Arrays.<String>asList(s));
                                        TeamManager.logger.info("COneKeyTeamMatch:一键喊话时间间隔60秒。 " + roleid);
                                        msg.ret = 1;
                                        Procedure.psendWhileCommit(roleid, msg);
                                        return true;
                                    } else {
                                        team.getTeamInfo().setOnekeytimestamp(systemTime);
                                        SStringRes msg2 = (SStringRes)ConfigManager.getInstance().getConf(SStringRes.class).get(286);
                                        if (msg2 == null) {
                                            TeamManager.logger.error("COneKeyTeamMatch:找不到字符串 " + roleid);
                                            msg.ret = 1;
                                            Procedure.psendWhileCommit(roleid, msg);
                                            return false;
                                        } else {
                                            String msgstring2 = msg2.msg;
                                            ArrayList<DisplayInfo> showinfos = new ArrayList();
                                            boolean ret = ChatChannel.getInstance().process(roleid, COneKeyTeamMatch.this.channeltype, COneKeyTeamMatch.this.text, msgstring2, showinfos, 1);
                                            if (ret) {
                                                MessageMgr.sendMsgNotify(roleid, 162025, (List)null);
                                            } else {
                                                msg.ret = 1;
                                            }

                                            Procedure.psendWhileCommit(roleid, msg);
                                            return ret;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            };
            onekeyteammatch.submit();
        }
    }

    public int getType() {
        return 794498;
    }

    public COneKeyTeamMatch() {
        this.text = "";
    }

    public COneKeyTeamMatch(int _channeltype_, String _text_) {
        this.channeltype = _channeltype_;
        this.text = _text_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.channeltype);
            _os_.marshal(this.text, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.channeltype = _os_.unmarshal_int();
        this.text = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof COneKeyTeamMatch) {
            COneKeyTeamMatch _o_ = (COneKeyTeamMatch)_o1_;
            if (this.channeltype != _o_.channeltype) {
                return false;
            } else {
                return this.text.equals(_o_.text);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.channeltype;
        _h_ += this.text.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.channeltype).append(",");
        _sb_.append("T").append(this.text.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
