//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.answerquestion.PAnswerSpecialquestQues;
import fire.pb.instancezone.PAnswerQuestion;
import fire.pb.mission.PCommitMajorMission;
import fire.pb.mission.Squestions;
import fire.pb.mission.util.AnswerCommitParam;
import gnet.link.Onlines;

public class CAnswerQuestion extends __CAnswerQuestion__ {
    public static final int PROTOCOL_TYPE = 795521;
    public int questionid;
    public int answerid;
    public int questiontype;
    public long npckey;
    public int xiangguanid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            if (this.questiontype == 2) {
                (new PAnswerQuestion(roleId, this)).submit();
            } else if (this.questiontype == 7) {
                (new PAnswerQuestion(roleId, this)).submit();
            } else {
                if (this.questiontype == 5) {
                    (new PAnswerSpecialquestQues(roleId, this.npckey, this.xiangguanid, this.questionid, this.answerid)).submit();
                } else if (this.questiontype == 1) {
                    int correct = ((Squestions)QuestionManager.getInstance().getAllQuestions().get(this.questionid)).correct;
                    SAskQuestion sAskQuestion = new SAskQuestion();
                    sAskQuestion.questiontype = this.questiontype;
                    sAskQuestion.xiangguanid = this.xiangguanid;
                    sAskQuestion.npckey = this.npckey;
                    if (correct == this.answerid) {
                        (new PCommitMajorMission(roleId, this.xiangguanid, new AnswerCommitParam(this.npckey, this.answerid), true)).submit();
                        sAskQuestion.lastresult = 1;
                        sAskQuestion.questionid = -1;
                    } else {
                        sAskQuestion.lastresult = -1;
                        int libid = ((Squestions)QuestionManager.getInstance().getAllQuestions().get(this.questionid)).questionsid;
                        Squestions sq = ((QuestionLib)QuestionManager.getInstance().getQuestionLibs().get(libid)).randomQuestion();
                        sAskQuestion.questionid = sq.id;
                        sAskQuestion.lastresult = -1;
                    }

                    Onlines.getInstance().send(roleId, sAskQuestion);
                    return;
                }

            }
        }
    }

    public int getType() {
        return 795521;
    }

    public CAnswerQuestion() {
    }

    public CAnswerQuestion(int _questionid_, int _answerid_, int _questiontype_, long _npckey_, int _xiangguanid_) {
        this.questionid = _questionid_;
        this.answerid = _answerid_;
        this.questiontype = _questiontype_;
        this.npckey = _npckey_;
        this.xiangguanid = _xiangguanid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questionid);
            _os_.marshal(this.answerid);
            _os_.marshal(this.questiontype);
            _os_.marshal(this.npckey);
            _os_.marshal(this.xiangguanid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questionid = _os_.unmarshal_int();
        this.answerid = _os_.unmarshal_int();
        this.questiontype = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.xiangguanid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAnswerQuestion) {
            CAnswerQuestion _o_ = (CAnswerQuestion)_o1_;
            if (this.questionid != _o_.questionid) {
                return false;
            } else if (this.answerid != _o_.answerid) {
                return false;
            } else if (this.questiontype != _o_.questiontype) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else {
                return this.xiangguanid == _o_.xiangguanid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questionid;
        _h_ += this.answerid;
        _h_ += this.questiontype;
        _h_ += (int)this.npckey;
        _h_ += this.xiangguanid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questionid).append(",");
        _sb_.append(this.answerid).append(",");
        _sb_.append(this.questiontype).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.xiangguanid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAnswerQuestion _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.questionid - _o_.questionid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.answerid - _o_.answerid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.questiontype - _o_.questiontype;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = Long.signum(this.npckey - _o_.npckey);
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.xiangguanid - _o_.xiangguanid;
                            return 0 != _c_ ? _c_ : _c_;
                        }
                    }
                }
            }
        }
    }
}
