//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.course.CourseManager;
import fire.pb.effect.PetImpl;
import fire.pb.item.AddItemResult;
import fire.pb.item.ItemBase;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.main.ModuleManager;
import gnet.link.Onlines;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetEquipItem;
import xbean.PetInfo;

public class Coutpetequip extends __Coutpetequip__ {
    public static final int PROTOCOL_TYPE = 817977;
    public int petkey;
    public int itemid;
    public int itemkey;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    PetColumn localPetColumn = new PetColumn(roleId, 1, false);
                    Pet localPet = localPetColumn.getPet(Coutpetequip.this.petkey);
                    PetInfo localPetInfo = localPet.getPetInfo();
                    PetImpl localPetImpl = new PetImpl(roleId, Coutpetequip.this.petkey);
                    List<PetEquipItem> localList = localPetInfo.getPetequipbag();
                    Pack bag = new Pack(roleId, false);
                    Iterator<PetEquipItem> localObject = localList.iterator();
                    PetEquipItem localPetEquipItem = (PetEquipItem)localObject.next();
                    if (localPetEquipItem.getItemid() == Coutpetequip.this.itemid) {
                        System.out.println("卸下装备ID" + localPetEquipItem.getItemid());
                        localObject.remove();
                        Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
                        if (itemmodule != null && localPetEquipItem != null) {
                            ItemBase givepetequip = itemmodule.getItemManager().genItemBase(localPetEquipItem.getItemid(), 1);
                            fire.pb.item.PetEquipItem petequipitem = (fire.pb.item.PetEquipItem)givepetequip;
                            petequipitem.getEquipAttr().setPos(localPetEquipItem.getPos());
                            petequipitem.getEquipAttr().getPro().putAll(localPetEquipItem.getPro());
                            petequipitem.settaozhuangid(localPetEquipItem.getTaozhuangid());
                            AddItemResult petaddequip = bag.doAddItem(givepetequip, -1, "宠物装备装入背包", YYLoggerTuJingEnum.tujing_Value_itemuseget, 0);
                            if (petaddequip != AddItemResult.SUCC) {
                                return false;
                            }
                        }
                    }

                    List<PetEquipItem> equips = localPetInfo.getPetequipbag();
                    int tz1 = 0;
                    int tz2 = 0;
                    int tz3 = 0;

                    for(PetEquipItem equip : equips) {
                        switch (equip.getPos()) {
                            case 1:
                                tz1 = equip.getTaozhuangid();
                                break;
                            case 2:
                                tz2 = equip.getTaozhuangid();
                                break;
                            case 3:
                                tz3 = equip.getTaozhuangid();
                        }
                    }

                    PPetEquipbyPet.deltaozhuang(roleId, Coutpetequip.this.petkey, tz1, tz2, tz3, false, localPetInfo);
                    localPetImpl.updateAllFinalAttrs();
                    SRefreshPetInfo localSRefreshPetInfo = new SRefreshPetInfo(localPet.getProtocolPet());
                    Procedure.psendWhileCommit(roleId, localSRefreshPetInfo);
                    localPet.updatePetScoreWhileChange();
                    CourseManager.checkAchieveCourse(roleId, 31, localPet.getPetInfo().getPetscore());
                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 817977;
    }

    public Coutpetequip() {
    }

    public Coutpetequip(int _petkey_, int _itemid_, int _itemkey_) {
        this.petkey = _petkey_;
        this.itemid = _itemid_;
        this.itemkey = _itemkey_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else if (this.itemid < 1) {
            return false;
        } else {
            return this.itemkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.itemid);
            _os_.marshal(this.itemkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.itemid = _os_.unmarshal_int();
        this.itemkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Coutpetequip) {
            Coutpetequip _o_ = (Coutpetequip)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.itemkey == _o_.itemkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.itemid;
        _h_ += this.itemkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Coutpetequip _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.itemid - _o_.itemid;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.itemkey - _o_.itemkey;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}
