//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class PetBean implements Marshal {
    public static final int FLAG_LOCK = 1;
    public static final int FLAG_BIND = 2;
    public int id;
    public int key;
    public String name;
    public int level;
    public int uselevel;
    public int xuemai;
    public int gengu;
    public int colour;
    public int hp;
    public int maxhp;
    public int mp;
    public int maxmp;
    public int attack;
    public int defend;
    public int speed;
    public int magicattack;
    public int magicdef;
    public byte scale;
    public BasicFightProperties initbfp;
    public BasicFightProperties bfp;
    public int point;
    public byte autoaddcons;
    public byte autoaddiq;
    public byte autoaddstr;
    public byte autoaddendu;
    public byte autoaddagi;
    public int pointresetcount;
    public long exp;
    public long nexp;
    public int attackapt;
    public int defendapt;
    public int phyforceapt;
    public int magicapt;
    public int speedapt;
    public int dodgeapt;
    public float growrate;
    public int life;
    public int kind;
    public LinkedList<Petskill> skills;
    public HashMap<Integer, Long> skillexpires;
    public byte flag;
    public long timeout;
    public long ownerid;
    public String ownername;
    public int rank;
    public short starid;
    public short practisetimes;
    public HashMap<Integer, Integer> zizhi;
    public int changegengu;
    public int skill_grids;
    public byte aptaddcount;
    public byte growrateaddcount;
    public short washcount;
    public int petscore;
    public int petbasescore;
    public int petdye1;
    public int petdye2;
    public int shenshouinccount;
    public long marketfreezeexpire;
    public LinkedList<Petskill> internals;
    public int qianye;
    public int longjing;
    public int pettaozhuang;

    public PetBean() {
        this.name = "";
        this.initbfp = new BasicFightProperties();
        this.bfp = new BasicFightProperties();
        this.skills = new LinkedList<>();
        this.skillexpires = new HashMap<>();
        this.ownername = "";
        this.zizhi = new HashMap<>();
        this.internals = new LinkedList<>();
    }

    public PetBean(int _id_, int _key_, String _name_, int _level_, int _uselevel_, int _xuemai_, int _gengu_, int _colour_, int _hp_, int _maxhp_, int _mp_, int _maxmp_, int _attack_, int _defend_, int _speed_, int _magicattack_, int _magicdef_, byte _scale_, BasicFightProperties _initbfp_, BasicFightProperties _bfp_, int _point_, byte _autoaddcons_, byte _autoaddiq_, byte _autoaddstr_, byte _autoaddendu_, byte _autoaddagi_, int _pointresetcount_, long _exp_, long _nexp_, int _attackapt_, int _defendapt_, int _phyforceapt_, int _magicapt_, int _speedapt_, int _dodgeapt_, float _growrate_, int _life_, int _kind_, LinkedList<Petskill> _skills_, HashMap<Integer, Long> _skillexpires_, byte _flag_, long _timeout_, long _ownerid_, String _ownername_, int _rank_, short _starid_, short _practisetimes_, HashMap<Integer, Integer> _zizhi_, int _changegengu_, int _skill_grids_, byte _aptaddcount_, byte _growrateaddcount_, short _washcount_, int _petscore_, int _petbasescore_, int _petdye1_, int _petdye2_, int _shenshouinccount_, long _marketfreezeexpire_, LinkedList<Petskill> _internals_, int _qianye_, int _longjing_, int _pettaozhuang_) {
        this.id = _id_;
        this.key = _key_;
        this.name = _name_;
        this.level = _level_;
        this.uselevel = _uselevel_;
        this.xuemai = _xuemai_;
        this.gengu = _gengu_;
        this.colour = _colour_;
        this.hp = _hp_;
        this.maxhp = _maxhp_;
        this.mp = _mp_;
        this.maxmp = _maxmp_;
        this.attack = _attack_;
        this.defend = _defend_;
        this.speed = _speed_;
        this.magicattack = _magicattack_;
        this.magicdef = _magicdef_;
        this.scale = _scale_;
        this.initbfp = _initbfp_;
        this.bfp = _bfp_;
        this.point = _point_;
        this.autoaddcons = _autoaddcons_;
        this.autoaddiq = _autoaddiq_;
        this.autoaddstr = _autoaddstr_;
        this.autoaddendu = _autoaddendu_;
        this.autoaddagi = _autoaddagi_;
        this.pointresetcount = _pointresetcount_;
        this.exp = _exp_;
        this.nexp = _nexp_;
        this.attackapt = _attackapt_;
        this.defendapt = _defendapt_;
        this.phyforceapt = _phyforceapt_;
        this.magicapt = _magicapt_;
        this.speedapt = _speedapt_;
        this.dodgeapt = _dodgeapt_;
        this.growrate = _growrate_;
        this.life = _life_;
        this.kind = _kind_;
        this.skills = _skills_;
        this.skillexpires = _skillexpires_;
        this.flag = _flag_;
        this.timeout = _timeout_;
        this.ownerid = _ownerid_;
        this.ownername = _ownername_;
        this.rank = _rank_;
        this.starid = _starid_;
        this.practisetimes = _practisetimes_;
        this.zizhi = _zizhi_;
        this.changegengu = _changegengu_;
        this.skill_grids = _skill_grids_;
        this.aptaddcount = _aptaddcount_;
        this.growrateaddcount = _growrateaddcount_;
        this.washcount = _washcount_;
        this.petscore = _petscore_;
        this.petbasescore = _petbasescore_;
        this.petdye1 = _petdye1_;
        this.petdye2 = _petdye2_;
        this.shenshouinccount = _shenshouinccount_;
        this.marketfreezeexpire = _marketfreezeexpire_;
        this.internals = _internals_;
        this.qianye = _qianye_;
        this.longjing = _longjing_;
        this.pettaozhuang = _pettaozhuang_;
    }

    public final boolean _validator_() {
        if (this.id < 1) {
            return false;
        } else if (!this.initbfp._validator_()) {
            return false;
        } else if (!this.bfp._validator_()) {
            return false;
        } else if (this.autoaddcons < 0) {
            return false;
        } else if (this.autoaddiq < 0) {
            return false;
        } else if (this.autoaddstr < 0) {
            return false;
        } else if (this.autoaddendu < 0) {
            return false;
        } else if (this.autoaddagi < 0) {
            return false;
        } else {
            for(Petskill _v_ : this.skills) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            for(Petskill _v_ : this.internals) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.key);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.uselevel);
        _os_.marshal(this.xuemai);
        _os_.marshal(this.gengu);
        _os_.marshal(this.colour);
        _os_.marshal(this.hp);
        _os_.marshal(this.maxhp);
        _os_.marshal(this.mp);
        _os_.marshal(this.maxmp);
        _os_.marshal(this.attack);
        _os_.marshal(this.defend);
        _os_.marshal(this.speed);
        _os_.marshal(this.magicattack);
        _os_.marshal(this.magicdef);
        _os_.marshal(this.scale);
        _os_.marshal(this.initbfp);
        _os_.marshal(this.bfp);
        _os_.marshal(this.point);
        _os_.marshal(this.autoaddcons);
        _os_.marshal(this.autoaddiq);
        _os_.marshal(this.autoaddstr);
        _os_.marshal(this.autoaddendu);
        _os_.marshal(this.autoaddagi);
        _os_.marshal(this.pointresetcount);
        _os_.marshal(this.exp);
        _os_.marshal(this.nexp);
        _os_.marshal(this.attackapt);
        _os_.marshal(this.defendapt);
        _os_.marshal(this.phyforceapt);
        _os_.marshal(this.magicapt);
        _os_.marshal(this.speedapt);
        _os_.marshal(this.dodgeapt);
        _os_.marshal(this.growrate);
        _os_.marshal(this.life);
        _os_.marshal(this.kind);
        _os_.compact_uint32(this.skills.size());

        for(Petskill _v_ : this.skills) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.skillexpires.size());

        for(Map.Entry<Integer, Long> _e_ : this.skillexpires.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Long)_e_.getValue());
        }

        _os_.marshal(this.flag);
        _os_.marshal(this.timeout);
        _os_.marshal(this.ownerid);
        _os_.marshal(this.ownername, "UTF-16LE");
        _os_.marshal(this.rank);
        _os_.marshal(this.starid);
        _os_.marshal(this.practisetimes);
        _os_.compact_uint32(this.zizhi.size());

        for(Map.Entry<Integer, Integer> _e_ : this.zizhi.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal(this.changegengu);
        _os_.marshal(this.skill_grids);
        _os_.marshal(this.aptaddcount);
        _os_.marshal(this.growrateaddcount);
        _os_.marshal(this.washcount);
        _os_.marshal(this.petscore);
        _os_.marshal(this.petbasescore);
        _os_.marshal(this.petdye1);
        _os_.marshal(this.petdye2);
        _os_.marshal(this.shenshouinccount);
        _os_.marshal(this.marketfreezeexpire);
        _os_.compact_uint32(this.internals.size());

        for(Petskill _v_ : this.internals) {
            _os_.marshal(_v_);
        }

        _os_.marshal(this.qianye);
        _os_.marshal(this.longjing);
        _os_.marshal(this.pettaozhuang);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.key = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.uselevel = _os_.unmarshal_int();
        this.xuemai = _os_.unmarshal_int();
        this.gengu = _os_.unmarshal_int();
        this.colour = _os_.unmarshal_int();
        this.hp = _os_.unmarshal_int();
        this.maxhp = _os_.unmarshal_int();
        this.mp = _os_.unmarshal_int();
        this.maxmp = _os_.unmarshal_int();
        this.attack = _os_.unmarshal_int();
        this.defend = _os_.unmarshal_int();
        this.speed = _os_.unmarshal_int();
        this.magicattack = _os_.unmarshal_int();
        this.magicdef = _os_.unmarshal_int();
        this.scale = _os_.unmarshal_byte();
        this.initbfp.unmarshal(_os_);
        this.bfp.unmarshal(_os_);
        this.point = _os_.unmarshal_int();
        this.autoaddcons = _os_.unmarshal_byte();
        this.autoaddiq = _os_.unmarshal_byte();
        this.autoaddstr = _os_.unmarshal_byte();
        this.autoaddendu = _os_.unmarshal_byte();
        this.autoaddagi = _os_.unmarshal_byte();
        this.pointresetcount = _os_.unmarshal_int();
        this.exp = _os_.unmarshal_long();
        this.nexp = _os_.unmarshal_long();
        this.attackapt = _os_.unmarshal_int();
        this.defendapt = _os_.unmarshal_int();
        this.phyforceapt = _os_.unmarshal_int();
        this.magicapt = _os_.unmarshal_int();
        this.speedapt = _os_.unmarshal_int();
        this.dodgeapt = _os_.unmarshal_int();
        this.growrate = _os_.unmarshal_float();
        this.life = _os_.unmarshal_int();
        this.kind = _os_.unmarshal_int();

        for(int i = _os_.uncompact_uint32(); i > 0; --i) {
            Petskill _v_ = new Petskill();
            _v_.unmarshal(_os_);
            this.skills.add(_v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            long _v_ = _os_.unmarshal_long();
            this.skillexpires.put(_k_, _v_);
        }

        this.flag = _os_.unmarshal_byte();
        this.timeout = _os_.unmarshal_long();
        this.ownerid = _os_.unmarshal_long();
        this.ownername = _os_.unmarshal_String("UTF-16LE");
        this.rank = _os_.unmarshal_int();
        this.starid = _os_.unmarshal_short();
        this.practisetimes = _os_.unmarshal_short();

        for(int var7 = _os_.uncompact_uint32(); var7 > 0; --var7) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.zizhi.put(_k_, _v_);
        }

        this.changegengu = _os_.unmarshal_int();
        this.skill_grids = _os_.unmarshal_int();
        this.aptaddcount = _os_.unmarshal_byte();
        this.growrateaddcount = _os_.unmarshal_byte();
        this.washcount = _os_.unmarshal_short();
        this.petscore = _os_.unmarshal_int();
        this.petbasescore = _os_.unmarshal_int();
        this.petdye1 = _os_.unmarshal_int();
        this.petdye2 = _os_.unmarshal_int();
        this.shenshouinccount = _os_.unmarshal_int();
        this.marketfreezeexpire = _os_.unmarshal_long();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Petskill _v_ = new Petskill();
            _v_.unmarshal(_os_);
            this.internals.add(_v_);
        }

        this.qianye = _os_.unmarshal_int();
        this.longjing = _os_.unmarshal_int();
        this.pettaozhuang = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PetBean) {
            PetBean _o_ = (PetBean)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.key != _o_.key) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.uselevel != _o_.uselevel) {
                return false;
            } else if (this.xuemai != _o_.xuemai) {
                return false;
            } else if (this.gengu != _o_.gengu) {
                return false;
            } else if (this.colour != _o_.colour) {
                return false;
            } else if (this.hp != _o_.hp) {
                return false;
            } else if (this.maxhp != _o_.maxhp) {
                return false;
            } else if (this.mp != _o_.mp) {
                return false;
            } else if (this.maxmp != _o_.maxmp) {
                return false;
            } else if (this.attack != _o_.attack) {
                return false;
            } else if (this.defend != _o_.defend) {
                return false;
            } else if (this.speed != _o_.speed) {
                return false;
            } else if (this.magicattack != _o_.magicattack) {
                return false;
            } else if (this.magicdef != _o_.magicdef) {
                return false;
            } else if (this.scale != _o_.scale) {
                return false;
            } else if (!this.initbfp.equals(_o_.initbfp)) {
                return false;
            } else if (!this.bfp.equals(_o_.bfp)) {
                return false;
            } else if (this.point != _o_.point) {
                return false;
            } else if (this.autoaddcons != _o_.autoaddcons) {
                return false;
            } else if (this.autoaddiq != _o_.autoaddiq) {
                return false;
            } else if (this.autoaddstr != _o_.autoaddstr) {
                return false;
            } else if (this.autoaddendu != _o_.autoaddendu) {
                return false;
            } else if (this.autoaddagi != _o_.autoaddagi) {
                return false;
            } else if (this.pointresetcount != _o_.pointresetcount) {
                return false;
            } else if (this.exp != _o_.exp) {
                return false;
            } else if (this.nexp != _o_.nexp) {
                return false;
            } else if (this.attackapt != _o_.attackapt) {
                return false;
            } else if (this.defendapt != _o_.defendapt) {
                return false;
            } else if (this.phyforceapt != _o_.phyforceapt) {
                return false;
            } else if (this.magicapt != _o_.magicapt) {
                return false;
            } else if (this.speedapt != _o_.speedapt) {
                return false;
            } else if (this.dodgeapt != _o_.dodgeapt) {
                return false;
            } else if (this.growrate != _o_.growrate) {
                return false;
            } else if (this.life != _o_.life) {
                return false;
            } else if (this.kind != _o_.kind) {
                return false;
            } else if (!this.skills.equals(_o_.skills)) {
                return false;
            } else if (!this.skillexpires.equals(_o_.skillexpires)) {
                return false;
            } else if (this.flag != _o_.flag) {
                return false;
            } else if (this.timeout != _o_.timeout) {
                return false;
            } else if (this.ownerid != _o_.ownerid) {
                return false;
            } else if (!this.ownername.equals(_o_.ownername)) {
                return false;
            } else if (this.rank != _o_.rank) {
                return false;
            } else if (this.starid != _o_.starid) {
                return false;
            } else if (this.practisetimes != _o_.practisetimes) {
                return false;
            } else if (!this.zizhi.equals(_o_.zizhi)) {
                return false;
            } else if (this.changegengu != _o_.changegengu) {
                return false;
            } else if (this.skill_grids != _o_.skill_grids) {
                return false;
            } else if (this.aptaddcount != _o_.aptaddcount) {
                return false;
            } else if (this.growrateaddcount != _o_.growrateaddcount) {
                return false;
            } else if (this.washcount != _o_.washcount) {
                return false;
            } else if (this.petscore != _o_.petscore) {
                return false;
            } else if (this.petbasescore != _o_.petbasescore) {
                return false;
            } else if (this.petdye1 != _o_.petdye1) {
                return false;
            } else if (this.petdye2 != _o_.petdye2) {
                return false;
            } else if (this.shenshouinccount != _o_.shenshouinccount) {
                return false;
            } else if (this.marketfreezeexpire != _o_.marketfreezeexpire) {
                return false;
            } else if (!this.internals.equals(_o_.internals)) {
                return false;
            } else if (this.qianye != _o_.qianye) {
                return false;
            } else if (this.longjing != _o_.longjing) {
                return false;
            } else {
                return this.pettaozhuang == _o_.pettaozhuang;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.key;
        _h_ += this.name.hashCode();
        _h_ += this.level;
        _h_ += this.uselevel;
        _h_ += this.xuemai;
        _h_ += this.gengu;
        _h_ += this.colour;
        _h_ += this.hp;
        _h_ += this.maxhp;
        _h_ += this.mp;
        _h_ += this.maxmp;
        _h_ += this.attack;
        _h_ += this.defend;
        _h_ += this.speed;
        _h_ += this.magicattack;
        _h_ += this.magicdef;
        _h_ += this.scale;
        _h_ += this.initbfp.hashCode();
        _h_ += this.bfp.hashCode();
        _h_ += this.point;
        _h_ += this.autoaddcons;
        _h_ += this.autoaddiq;
        _h_ += this.autoaddstr;
        _h_ += this.autoaddendu;
        _h_ += this.autoaddagi;
        _h_ += this.pointresetcount;
        _h_ += (int)this.exp;
        _h_ += (int)this.nexp;
        _h_ += this.attackapt;
        _h_ += this.defendapt;
        _h_ += this.phyforceapt;
        _h_ += this.magicapt;
        _h_ += this.speedapt;
        _h_ += this.dodgeapt;
        _h_ += Float.floatToIntBits(this.growrate);
        _h_ += this.life;
        _h_ += this.kind;
        _h_ += this.skills.hashCode();
        _h_ += this.skillexpires.hashCode();
        _h_ += this.flag;
        _h_ += (int)this.timeout;
        _h_ += (int)this.ownerid;
        _h_ += this.ownername.hashCode();
        _h_ += this.rank;
        _h_ += this.starid;
        _h_ += this.practisetimes;
        _h_ += this.zizhi.hashCode();
        _h_ += this.changegengu;
        _h_ += this.skill_grids;
        _h_ += this.aptaddcount;
        _h_ += this.growrateaddcount;
        _h_ += this.washcount;
        _h_ += this.petscore;
        _h_ += this.petbasescore;
        _h_ += this.petdye1;
        _h_ += this.petdye2;
        _h_ += this.shenshouinccount;
        _h_ += (int)this.marketfreezeexpire;
        _h_ += this.internals.hashCode();
        _h_ += this.qianye;
        _h_ += this.longjing;
        _h_ += this.pettaozhuang;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.key).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.uselevel).append(",");
        _sb_.append(this.xuemai).append(",");
        _sb_.append(this.gengu).append(",");
        _sb_.append(this.colour).append(",");
        _sb_.append(this.hp).append(",");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.mp).append(",");
        _sb_.append(this.maxmp).append(",");
        _sb_.append(this.attack).append(",");
        _sb_.append(this.defend).append(",");
        _sb_.append(this.speed).append(",");
        _sb_.append(this.magicattack).append(",");
        _sb_.append(this.magicdef).append(",");
        _sb_.append(this.scale).append(",");
        _sb_.append(this.initbfp).append(",");
        _sb_.append(this.bfp).append(",");
        _sb_.append(this.point).append(",");
        _sb_.append(this.autoaddcons).append(",");
        _sb_.append(this.autoaddiq).append(",");
        _sb_.append(this.autoaddstr).append(",");
        _sb_.append(this.autoaddendu).append(",");
        _sb_.append(this.autoaddagi).append(",");
        _sb_.append(this.pointresetcount).append(",");
        _sb_.append(this.exp).append(",");
        _sb_.append(this.nexp).append(",");
        _sb_.append(this.attackapt).append(",");
        _sb_.append(this.defendapt).append(",");
        _sb_.append(this.phyforceapt).append(",");
        _sb_.append(this.magicapt).append(",");
        _sb_.append(this.speedapt).append(",");
        _sb_.append(this.dodgeapt).append(",");
        _sb_.append(this.growrate).append(",");
        _sb_.append(this.life).append(",");
        _sb_.append(this.kind).append(",");
        _sb_.append(this.skills).append(",");
        _sb_.append(this.skillexpires).append(",");
        _sb_.append(this.flag).append(",");
        _sb_.append(this.timeout).append(",");
        _sb_.append(this.ownerid).append(",");
        _sb_.append("T").append(this.ownername.length()).append(",");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.starid).append(",");
        _sb_.append(this.practisetimes).append(",");
        _sb_.append(this.zizhi).append(",");
        _sb_.append(this.changegengu).append(",");
        _sb_.append(this.skill_grids).append(",");
        _sb_.append(this.aptaddcount).append(",");
        _sb_.append(this.growrateaddcount).append(",");
        _sb_.append(this.washcount).append(",");
        _sb_.append(this.petscore).append(",");
        _sb_.append(this.petbasescore).append(",");
        _sb_.append(this.petdye1).append(",");
        _sb_.append(this.petdye2).append(",");
        _sb_.append(this.shenshouinccount).append(",");
        _sb_.append(this.marketfreezeexpire).append(",");
        _sb_.append(this.internals).append(",");
        _sb_.append(this.qianye).append(",");
        _sb_.append(this.longjing).append(",");
        _sb_.append(this.pettaozhuang).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
