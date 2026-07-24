//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.title.TitleInfo;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class RoleDetail implements Marshal {
    public long roleid;
    public String rolename;
    public int zhuansheng;
    public int level;
    public int school;
    public int shape;
    public int title;
    public long lastlogin;
    public int hp;
    public int uplimithp;
    public int maxhp;
    public int mp;
    public int magicattack;
    public int maxmp;
    public int magicdef;
    public int sp;
    public int seal;
    public int maxsp;
    public int hit;
    public int damage;
    public int heal_critc_level;
    public int defend;
    public int phy_critc_level;
    public int speed;
    public int magic_critc_level;
    public int dodge;
    public int anti_phy_critc_level;
    public int medical;
    public int unseal;
    public int anti_critc_level;
    public float phy_critc_pct;
    public float magic_critc_pct;
    public float heal_critc_pct;
    public int anti_magic_critc_level;
    public int energy;
    public int enlimit;
    public RoleBasicFightProperties bfp;
    public HashMap<Integer, Integer> point;
    public int pointscheme;
    public int schemechanges;
    public int schoolvalue;
    public int reputation;
    public long exp;
    public long nexp;
    public int showpet;
    public int petmaxnum;
    public ArrayList<PetBean> pets;
    public HashMap<Integer, Integer> sysconfigmap;
    public HashMap<Integer, Integer> lineconfigmap;
    public HashMap<Integer, TitleInfo> titles;
    public HashMap<Integer, FormBean> learnedformsmap;
    public HashMap<Byte, Integer> components;
    public int activeness;
    public int factionvalue;
    public long masterid;
    public byte isprotected;
    public byte wrongpwdtimes;
    public int petindex;
    public int kongzhijiacheng;
    public int kongzhimianyi;
    public int zhiliaojiashen;
    public int wulidikang;
    public int fashudikang;
    public int fashuchuantou;
    public int wulichuantou;
    public HashMap<Integer, Bag> baginfo;
    public long rolecreatetime;
    public HashMap<Integer, String> depotnameinfo;

    public RoleDetail() {
        this.rolename = "";
        this.bfp = new RoleBasicFightProperties();
        this.point = new HashMap();
        this.pets = new ArrayList();
        this.sysconfigmap = new HashMap();
        this.lineconfigmap = new HashMap();
        this.titles = new HashMap();
        this.learnedformsmap = new HashMap();
        this.components = new HashMap();
        this.baginfo = new HashMap();
        this.depotnameinfo = new HashMap();
    }

    public RoleDetail(long _roleid_, String _rolename_, int _zhuansheng_, int _level_, int _school_, int _shape_, int _title_, long _lastlogin_, int _hp_, int _uplimithp_, int _maxhp_, int _mp_, int _magicattack_, int _maxmp_, int _magicdef_, int _sp_, int _seal_, int _maxsp_, int _hit_, int _damage_, int _heal_critc_level_, int _defend_, int _phy_critc_level_, int _speed_, int _magic_critc_level_, int _dodge_, int _anti_phy_critc_level_, int _medical_, int _unseal_, int _anti_critc_level_, float _phy_critc_pct_, float _magic_critc_pct_, float _heal_critc_pct_, int _anti_magic_critc_level_, int _energy_, int _enlimit_, RoleBasicFightProperties _bfp_, HashMap<Integer, Integer> _point_, int _pointscheme_, int _schemechanges_, int _schoolvalue_, int _reputation_, long _exp_, long _nexp_, int _showpet_, int _petmaxnum_, ArrayList<PetBean> _pets_, HashMap<Integer, Integer> _sysconfigmap_, HashMap<Integer, Integer> _lineconfigmap_, HashMap<Integer, TitleInfo> _titles_, HashMap<Integer, FormBean> _learnedformsmap_, HashMap<Byte, Integer> _components_, int _activeness_, int _factionvalue_, long _masterid_, byte _isprotected_, byte _wrongpwdtimes_, int _petindex_, int _kongzhijiacheng_, int _kongzhimianyi_, int _zhiliaojiashen_, int _wulidikang_, int _fashudikang_, int _fashuchuantou_, int _wulichuantou_, HashMap<Integer, Bag> _baginfo_, long _rolecreatetime_, HashMap<Integer, String> _depotnameinfo_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.zhuansheng = _zhuansheng_;
        this.level = _level_;
        this.school = _school_;
        this.shape = _shape_;
        this.title = _title_;
        this.lastlogin = _lastlogin_;
        this.hp = _hp_;
        this.uplimithp = _uplimithp_;
        this.maxhp = _maxhp_;
        this.mp = _mp_;
        this.magicattack = _magicattack_;
        this.maxmp = _maxmp_;
        this.magicdef = _magicdef_;
        this.sp = _sp_;
        this.seal = _seal_;
        this.maxsp = _maxsp_;
        this.hit = _hit_;
        this.damage = _damage_;
        this.heal_critc_level = _heal_critc_level_;
        this.defend = _defend_;
        this.phy_critc_level = _phy_critc_level_;
        this.speed = _speed_;
        this.magic_critc_level = _magic_critc_level_;
        this.dodge = _dodge_;
        this.anti_phy_critc_level = _anti_phy_critc_level_;
        this.medical = _medical_;
        this.unseal = _unseal_;
        this.anti_critc_level = _anti_critc_level_;
        this.phy_critc_pct = _phy_critc_pct_;
        this.magic_critc_pct = _magic_critc_pct_;
        this.heal_critc_pct = _heal_critc_pct_;
        this.anti_magic_critc_level = _anti_magic_critc_level_;
        this.energy = _energy_;
        this.enlimit = _enlimit_;
        this.bfp = _bfp_;
        this.point = _point_;
        this.pointscheme = _pointscheme_;
        this.schemechanges = _schemechanges_;
        this.schoolvalue = _schoolvalue_;
        this.reputation = _reputation_;
        this.exp = _exp_;
        this.nexp = _nexp_;
        this.showpet = _showpet_;
        this.petmaxnum = _petmaxnum_;
        this.pets = _pets_;
        this.sysconfigmap = _sysconfigmap_;
        this.lineconfigmap = _lineconfigmap_;
        this.titles = _titles_;
        this.learnedformsmap = _learnedformsmap_;
        this.components = _components_;
        this.activeness = _activeness_;
        this.factionvalue = _factionvalue_;
        this.masterid = _masterid_;
        this.isprotected = _isprotected_;
        this.wrongpwdtimes = _wrongpwdtimes_;
        this.petindex = _petindex_;
        this.kongzhijiacheng = _kongzhijiacheng_;
        this.kongzhimianyi = _kongzhimianyi_;
        this.zhiliaojiashen = _zhiliaojiashen_;
        this.wulidikang = _wulidikang_;
        this.fashudikang = _fashudikang_;
        this.fashuchuantou = _fashuchuantou_;
        this.wulichuantou = _wulichuantou_;
        this.baginfo = _baginfo_;
        this.rolecreatetime = _rolecreatetime_;
        this.depotnameinfo = _depotnameinfo_;
    }

    public final boolean _validator_() {
        if (this.roleid < 1L) {
            return false;
        } else if (this.level < 1) {
            return false;
        } else if (this.title < -1) {
            return false;
        } else if (!this.bfp._validator_()) {
            return false;
        } else {
            for(PetBean _v_ : this.pets) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            for(Map.Entry<Integer, TitleInfo> _e_ : this.titles.entrySet()) {
                if (!((TitleInfo)_e_.getValue())._validator_()) {
                    return false;
                }
            }

            for(Map.Entry<Integer, FormBean> _e_ : this.learnedformsmap.entrySet()) {
                if (!((FormBean)_e_.getValue())._validator_()) {
                    return false;
                }
            }

            for(Map.Entry<Integer, Bag> _e_ : this.baginfo.entrySet()) {
                if (!((Bag)_e_.getValue())._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.zhuansheng);
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.shape);
        _os_.marshal(this.title);
        _os_.marshal(this.lastlogin);
        _os_.marshal(this.hp);
        _os_.marshal(this.uplimithp);
        _os_.marshal(this.maxhp);
        _os_.marshal(this.mp);
        _os_.marshal(this.magicattack);
        _os_.marshal(this.maxmp);
        _os_.marshal(this.magicdef);
        _os_.marshal(this.sp);
        _os_.marshal(this.seal);
        _os_.marshal(this.maxsp);
        _os_.marshal(this.hit);
        _os_.marshal(this.damage);
        _os_.marshal(this.heal_critc_level);
        _os_.marshal(this.defend);
        _os_.marshal(this.phy_critc_level);
        _os_.marshal(this.speed);
        _os_.marshal(this.magic_critc_level);
        _os_.marshal(this.dodge);
        _os_.marshal(this.anti_phy_critc_level);
        _os_.marshal(this.medical);
        _os_.marshal(this.unseal);
        _os_.marshal(this.anti_critc_level);
        _os_.marshal(this.phy_critc_pct);
        _os_.marshal(this.magic_critc_pct);
        _os_.marshal(this.heal_critc_pct);
        _os_.marshal(this.anti_magic_critc_level);
        _os_.marshal(this.energy);
        _os_.marshal(this.enlimit);
        _os_.marshal(this.bfp);
        _os_.compact_uint32(this.point.size());

        for(Map.Entry<Integer, Integer> _e_ : this.point.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal(this.pointscheme);
        _os_.marshal(this.schemechanges);
        _os_.marshal(this.schoolvalue);
        _os_.marshal(this.reputation);
        _os_.marshal(this.exp);
        _os_.marshal(this.nexp);
        _os_.marshal(this.showpet);
        _os_.marshal(this.petmaxnum);
        _os_.compact_uint32(this.pets.size());

        for(PetBean _v_ : this.pets) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.sysconfigmap.size());

        for(Map.Entry<Integer, Integer> _e_ : this.sysconfigmap.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.lineconfigmap.size());

        for(Map.Entry<Integer, Integer> _e_ : this.lineconfigmap.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.titles.size());

        for(Map.Entry<Integer, TitleInfo> _e_ : this.titles.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        _os_.compact_uint32(this.learnedformsmap.size());

        for(Map.Entry<Integer, FormBean> _e_ : this.learnedformsmap.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal(this.activeness);
        _os_.marshal(this.factionvalue);
        _os_.marshal(this.masterid);
        _os_.marshal(this.isprotected);
        _os_.marshal(this.wrongpwdtimes);
        _os_.marshal(this.petindex);
        _os_.marshal(this.kongzhijiacheng);
        _os_.marshal(this.kongzhimianyi);
        _os_.marshal(this.zhiliaojiashen);
        _os_.marshal(this.wulidikang);
        _os_.marshal(this.fashudikang);
        _os_.marshal(this.fashuchuantou);
        _os_.marshal(this.wulichuantou);
        _os_.compact_uint32(this.baginfo.size());

        for(Map.Entry<Integer, Bag> _e_ : this.baginfo.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        _os_.marshal(this.rolecreatetime);
        _os_.compact_uint32(this.depotnameinfo.size());

        for(Map.Entry<Integer, String> _e_ : this.depotnameinfo.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((String)_e_.getValue(), "UTF-16LE");
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.zhuansheng = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.title = _os_.unmarshal_int();
        this.lastlogin = _os_.unmarshal_long();
        this.hp = _os_.unmarshal_int();
        this.uplimithp = _os_.unmarshal_int();
        this.maxhp = _os_.unmarshal_int();
        this.mp = _os_.unmarshal_int();
        this.magicattack = _os_.unmarshal_int();
        this.maxmp = _os_.unmarshal_int();
        this.magicdef = _os_.unmarshal_int();
        this.sp = _os_.unmarshal_int();
        this.seal = _os_.unmarshal_int();
        this.maxsp = _os_.unmarshal_int();
        this.hit = _os_.unmarshal_int();
        this.damage = _os_.unmarshal_int();
        this.heal_critc_level = _os_.unmarshal_int();
        this.defend = _os_.unmarshal_int();
        this.phy_critc_level = _os_.unmarshal_int();
        this.speed = _os_.unmarshal_int();
        this.magic_critc_level = _os_.unmarshal_int();
        this.dodge = _os_.unmarshal_int();
        this.anti_phy_critc_level = _os_.unmarshal_int();
        this.medical = _os_.unmarshal_int();
        this.unseal = _os_.unmarshal_int();
        this.anti_critc_level = _os_.unmarshal_int();
        this.phy_critc_pct = _os_.unmarshal_float();
        this.magic_critc_pct = _os_.unmarshal_float();
        this.heal_critc_pct = _os_.unmarshal_float();
        this.anti_magic_critc_level = _os_.unmarshal_int();
        this.energy = _os_.unmarshal_int();
        this.enlimit = _os_.unmarshal_int();
        this.bfp.unmarshal(_os_);

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.point.put(_k_, _v_);
        }

        this.pointscheme = _os_.unmarshal_int();
        this.schemechanges = _os_.unmarshal_int();
        this.schoolvalue = _os_.unmarshal_int();
        this.reputation = _os_.unmarshal_int();
        this.exp = _os_.unmarshal_long();
        this.nexp = _os_.unmarshal_long();
        this.showpet = _os_.unmarshal_int();
        this.petmaxnum = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            PetBean _v_ = new PetBean();
            _v_.unmarshal(_os_);
            this.pets.add(_v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.sysconfigmap.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.lineconfigmap.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            TitleInfo _v_ = new TitleInfo();
            _v_.unmarshal(_os_);
            this.titles.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            FormBean _v_ = new FormBean();
            _v_.unmarshal(_os_);
            this.learnedformsmap.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        this.activeness = _os_.unmarshal_int();
        this.factionvalue = _os_.unmarshal_int();
        this.masterid = _os_.unmarshal_long();
        this.isprotected = _os_.unmarshal_byte();
        this.wrongpwdtimes = _os_.unmarshal_byte();
        this.petindex = _os_.unmarshal_int();
        this.kongzhijiacheng = _os_.unmarshal_int();
        this.kongzhimianyi = _os_.unmarshal_int();
        this.zhiliaojiashen = _os_.unmarshal_int();
        this.wulidikang = _os_.unmarshal_int();
        this.fashudikang = _os_.unmarshal_int();
        this.fashuchuantou = _os_.unmarshal_int();
        this.wulichuantou = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            Bag _v_ = new Bag();
            _v_.unmarshal(_os_);
            this.baginfo.put(_k_, _v_);
        }

        this.rolecreatetime = _os_.unmarshal_long();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            String _v_ = _os_.unmarshal_String("UTF-16LE");
            this.depotnameinfo.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleDetail) {
            RoleDetail _o_ = (RoleDetail)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.zhuansheng != _o_.zhuansheng) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.title != _o_.title) {
                return false;
            } else if (this.lastlogin != _o_.lastlogin) {
                return false;
            } else if (this.hp != _o_.hp) {
                return false;
            } else if (this.uplimithp != _o_.uplimithp) {
                return false;
            } else if (this.maxhp != _o_.maxhp) {
                return false;
            } else if (this.mp != _o_.mp) {
                return false;
            } else if (this.magicattack != _o_.magicattack) {
                return false;
            } else if (this.maxmp != _o_.maxmp) {
                return false;
            } else if (this.magicdef != _o_.magicdef) {
                return false;
            } else if (this.sp != _o_.sp) {
                return false;
            } else if (this.seal != _o_.seal) {
                return false;
            } else if (this.maxsp != _o_.maxsp) {
                return false;
            } else if (this.hit != _o_.hit) {
                return false;
            } else if (this.damage != _o_.damage) {
                return false;
            } else if (this.heal_critc_level != _o_.heal_critc_level) {
                return false;
            } else if (this.defend != _o_.defend) {
                return false;
            } else if (this.phy_critc_level != _o_.phy_critc_level) {
                return false;
            } else if (this.speed != _o_.speed) {
                return false;
            } else if (this.magic_critc_level != _o_.magic_critc_level) {
                return false;
            } else if (this.dodge != _o_.dodge) {
                return false;
            } else if (this.anti_phy_critc_level != _o_.anti_phy_critc_level) {
                return false;
            } else if (this.medical != _o_.medical) {
                return false;
            } else if (this.unseal != _o_.unseal) {
                return false;
            } else if (this.anti_critc_level != _o_.anti_critc_level) {
                return false;
            } else if (this.phy_critc_pct != _o_.phy_critc_pct) {
                return false;
            } else if (this.magic_critc_pct != _o_.magic_critc_pct) {
                return false;
            } else if (this.heal_critc_pct != _o_.heal_critc_pct) {
                return false;
            } else if (this.anti_magic_critc_level != _o_.anti_magic_critc_level) {
                return false;
            } else if (this.energy != _o_.energy) {
                return false;
            } else if (this.enlimit != _o_.enlimit) {
                return false;
            } else if (!this.bfp.equals(_o_.bfp)) {
                return false;
            } else if (!this.point.equals(_o_.point)) {
                return false;
            } else if (this.pointscheme != _o_.pointscheme) {
                return false;
            } else if (this.schemechanges != _o_.schemechanges) {
                return false;
            } else if (this.schoolvalue != _o_.schoolvalue) {
                return false;
            } else if (this.reputation != _o_.reputation) {
                return false;
            } else if (this.exp != _o_.exp) {
                return false;
            } else if (this.nexp != _o_.nexp) {
                return false;
            } else if (this.showpet != _o_.showpet) {
                return false;
            } else if (this.petmaxnum != _o_.petmaxnum) {
                return false;
            } else if (!this.pets.equals(_o_.pets)) {
                return false;
            } else if (!this.sysconfigmap.equals(_o_.sysconfigmap)) {
                return false;
            } else if (!this.lineconfigmap.equals(_o_.lineconfigmap)) {
                return false;
            } else if (!this.titles.equals(_o_.titles)) {
                return false;
            } else if (!this.learnedformsmap.equals(_o_.learnedformsmap)) {
                return false;
            } else if (!this.components.equals(_o_.components)) {
                return false;
            } else if (this.activeness != _o_.activeness) {
                return false;
            } else if (this.factionvalue != _o_.factionvalue) {
                return false;
            } else if (this.masterid != _o_.masterid) {
                return false;
            } else if (this.isprotected != _o_.isprotected) {
                return false;
            } else if (this.wrongpwdtimes != _o_.wrongpwdtimes) {
                return false;
            } else if (this.petindex != _o_.petindex) {
                return false;
            } else if (this.kongzhijiacheng != _o_.kongzhijiacheng) {
                return false;
            } else if (this.kongzhimianyi != _o_.kongzhimianyi) {
                return false;
            } else if (this.zhiliaojiashen != _o_.zhiliaojiashen) {
                return false;
            } else if (this.wulidikang != _o_.wulidikang) {
                return false;
            } else if (this.fashudikang != _o_.fashudikang) {
                return false;
            } else if (this.fashuchuantou != _o_.fashuchuantou) {
                return false;
            } else if (this.wulichuantou != _o_.wulichuantou) {
                return false;
            } else if (!this.baginfo.equals(_o_.baginfo)) {
                return false;
            } else if (this.rolecreatetime != _o_.rolecreatetime) {
                return false;
            } else {
                return this.depotnameinfo.equals(_o_.depotnameinfo);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.zhuansheng;
        _h_ += this.level;
        _h_ += this.school;
        _h_ += this.shape;
        _h_ += this.title;
        _h_ += (int)this.lastlogin;
        _h_ += this.hp;
        _h_ += this.uplimithp;
        _h_ += this.maxhp;
        _h_ += this.mp;
        _h_ += this.magicattack;
        _h_ += this.maxmp;
        _h_ += this.magicdef;
        _h_ += this.sp;
        _h_ += this.seal;
        _h_ += this.maxsp;
        _h_ += this.hit;
        _h_ += this.damage;
        _h_ += this.heal_critc_level;
        _h_ += this.defend;
        _h_ += this.phy_critc_level;
        _h_ += this.speed;
        _h_ += this.magic_critc_level;
        _h_ += this.dodge;
        _h_ += this.anti_phy_critc_level;
        _h_ += this.medical;
        _h_ += this.unseal;
        _h_ += this.anti_critc_level;
        _h_ += Float.floatToIntBits(this.phy_critc_pct);
        _h_ += Float.floatToIntBits(this.magic_critc_pct);
        _h_ += Float.floatToIntBits(this.heal_critc_pct);
        _h_ += this.anti_magic_critc_level;
        _h_ += this.energy;
        _h_ += this.enlimit;
        _h_ += this.bfp.hashCode();
        _h_ += this.point.hashCode();
        _h_ += this.pointscheme;
        _h_ += this.schemechanges;
        _h_ += this.schoolvalue;
        _h_ += this.reputation;
        _h_ += (int)this.exp;
        _h_ += (int)this.nexp;
        _h_ += this.showpet;
        _h_ += this.petmaxnum;
        _h_ += this.pets.hashCode();
        _h_ += this.sysconfigmap.hashCode();
        _h_ += this.lineconfigmap.hashCode();
        _h_ += this.titles.hashCode();
        _h_ += this.learnedformsmap.hashCode();
        _h_ += this.components.hashCode();
        _h_ += this.activeness;
        _h_ += this.factionvalue;
        _h_ += (int)this.masterid;
        _h_ += this.isprotected;
        _h_ += this.wrongpwdtimes;
        _h_ += this.petindex;
        _h_ += this.kongzhijiacheng;
        _h_ += this.kongzhimianyi;
        _h_ += this.zhiliaojiashen;
        _h_ += this.wulidikang;
        _h_ += this.fashudikang;
        _h_ += this.fashuchuantou;
        _h_ += this.wulichuantou;
        _h_ += this.baginfo.hashCode();
        _h_ += (int)this.rolecreatetime;
        _h_ += this.depotnameinfo.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.zhuansheng).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.title).append(",");
        _sb_.append(this.lastlogin).append(",");
        _sb_.append(this.hp).append(",");
        _sb_.append(this.uplimithp).append(",");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.mp).append(",");
        _sb_.append(this.magicattack).append(",");
        _sb_.append(this.maxmp).append(",");
        _sb_.append(this.magicdef).append(",");
        _sb_.append(this.sp).append(",");
        _sb_.append(this.seal).append(",");
        _sb_.append(this.maxsp).append(",");
        _sb_.append(this.hit).append(",");
        _sb_.append(this.damage).append(",");
        _sb_.append(this.heal_critc_level).append(",");
        _sb_.append(this.defend).append(",");
        _sb_.append(this.phy_critc_level).append(",");
        _sb_.append(this.speed).append(",");
        _sb_.append(this.magic_critc_level).append(",");
        _sb_.append(this.dodge).append(",");
        _sb_.append(this.anti_phy_critc_level).append(",");
        _sb_.append(this.medical).append(",");
        _sb_.append(this.unseal).append(",");
        _sb_.append(this.anti_critc_level).append(",");
        _sb_.append(this.phy_critc_pct).append(",");
        _sb_.append(this.magic_critc_pct).append(",");
        _sb_.append(this.heal_critc_pct).append(",");
        _sb_.append(this.anti_magic_critc_level).append(",");
        _sb_.append(this.energy).append(",");
        _sb_.append(this.enlimit).append(",");
        _sb_.append(this.bfp).append(",");
        _sb_.append(this.point).append(",");
        _sb_.append(this.pointscheme).append(",");
        _sb_.append(this.schemechanges).append(",");
        _sb_.append(this.schoolvalue).append(",");
        _sb_.append(this.reputation).append(",");
        _sb_.append(this.exp).append(",");
        _sb_.append(this.nexp).append(",");
        _sb_.append(this.showpet).append(",");
        _sb_.append(this.petmaxnum).append(",");
        _sb_.append(this.pets).append(",");
        _sb_.append(this.sysconfigmap).append(",");
        _sb_.append(this.lineconfigmap).append(",");
        _sb_.append(this.titles).append(",");
        _sb_.append(this.learnedformsmap).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(this.activeness).append(",");
        _sb_.append(this.factionvalue).append(",");
        _sb_.append(this.masterid).append(",");
        _sb_.append(this.isprotected).append(",");
        _sb_.append(this.wrongpwdtimes).append(",");
        _sb_.append(this.petindex).append(",");
        _sb_.append(this.kongzhijiacheng).append(",");
        _sb_.append(this.kongzhimianyi).append(",");
        _sb_.append(this.zhiliaojiashen).append(",");
        _sb_.append(this.wulidikang).append(",");
        _sb_.append(this.fashudikang).append(",");
        _sb_.append(this.fashuchuantou).append(",");
        _sb_.append(this.wulichuantou).append(",");
        _sb_.append(this.baginfo).append(",");
        _sb_.append(this.rolecreatetime).append(",");
        _sb_.append(this.depotnameinfo).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
