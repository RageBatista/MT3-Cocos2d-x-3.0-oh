//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.Module;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipItemShuXing;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Pack;
import fire.pb.item.SAddItem;
import fire.pb.item.SGetItemTips;
import fire.pb.item.SXilianEffect;
import fire.pb.item.make.BoDongDuan;
import fire.pb.item.make.ItemMakeUtil;
import fire.pb.item.make.ShuXing;
import fire.pb.item.make.ZhuangBeiShuXing;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;

public class PDianhuaWeapon extends Procedure {
    private static Logger logger = Logger.getLogger("ITEM");
    public static final Map<Integer, SXilianEffect> XILIANEFFECT_CFGS = ConfigManager.getInstance().getConf(SXilianEffect.class);
    private final long roleId;
    private final int equipKey;
    private final int dianhuashiTypeId;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;

    public PDianhuaWeapon(long paramLong, int paramInt1, int paramInt2) {
        this.roleId = paramLong;
        this.equipKey = paramInt1;
        this.dianhuashiTypeId = paramInt2;
    }

    protected boolean process() throws Exception {
        Properties localProperties = xtable.Properties.get(this.roleId);
        if (localProperties == null) {
            return false;
        } else if (Module.existState(this.roleId, 507004)) {
            MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
            logger.error("战斗状态下无法使用装备点化功能");
            return false;
        } else {
            ItemShuXing localItemShuXing = fire.pb.item.Module.getInstance().getItemManager().getAttr(this.dianhuashiTypeId);
            if (localItemShuXing == null) {
                logger.error("点化石不存在");
                return false;
            } else {
                Pack localPack = new Pack(this.roleId, false);
                ItemBase localItemBase = localPack.getItem(this.equipKey);
                if (localItemBase != null && localItemBase instanceof EquipItem) {
                    EquipItem localEquipItem = (EquipItem)localItemBase;
                    if ((localItemBase.getFlags() & 4) != 0) {
                        logger.error("拍卖的武器无法使用点化功能");
                        return false;
                    } else {
                        EquipItemShuXing localEquipItemShuXing1 = localEquipItem.getItemAttr();
                        int i = localEquipItemShuXing1.getBaseAttrId();
                        ZhuangBeiShuXing localZhuangBeiShuXing1 = (ZhuangBeiShuXing)ItemMakeUtil.effectConfigs.get(i);
                        if (localZhuangBeiShuXing1 == null) {
                            return false;
                        } else {
                            ItemMaps localItemMaps = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                            if (localItemMaps == null) {
                                logger.error("角色id " + this.roleId + "点化装备\t背包错误");
                                return false;
                            } else {
                                int j = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(490).getValue());
                                int jj = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(496).getValue());
                                int m;
                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() < j) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        System.out.println(m);
                                        System.out.println(j);
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 2) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 1, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 2 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 3) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 2, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 3 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 4) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 3, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 4 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 5) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 4, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 5 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 6) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 5, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 6 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 7) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 6, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 7 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 8) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 7, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 8 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 9) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 8, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 9 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 10) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 9, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 10 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 11) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 10, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 11 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 12) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 11, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 12 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 13) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 12, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 13 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 14) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 13, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 14 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 15) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 14, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 15 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 16) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 15, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 16 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 17) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 16, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 17 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 18) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 17, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 18 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 19) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 18, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 19 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 20) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 19, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 20 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 21) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 20, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 21 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 22) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 21, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 22 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 23) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 22, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 23 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 24) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 23, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 24 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 25) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 24, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 25 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 26) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 25, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 26 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 27) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 26, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 27 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 28) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 27, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 28 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 29) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 28, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                if (localEquipItem.getEquipAttr().getTaozhuangeffectid() >= j * 29 && localEquipItem.getEquipAttr().getTaozhuangeffectid() < j * 30) {
                                    m = localItemMaps.removeItemById(this.dianhuashiTypeId, jj + 29, YYLoggerTuJingEnum.tujing_Value_shenshoucost, this.dianhuashiTypeId, "点化装备");
                                    if (m < jj) {
                                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 191189, (List)null);
                                        return false;
                                    }
                                }

                                m = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(488).getValue());
                                long l = localPack.subGold((long)(-m), "点化装备消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                                if (l != (long)(-m)) {
                                    return false;
                                } else {
                                    EquipItemShuXing equipItemShuXing1 = localEquipItem.getItemAttr();
                                    int n = equipItemShuXing1.getBaseAttrId();
                                    ZhuangBeiShuXing zhuangBeiShuXing = (ZhuangBeiShuXing)ItemMakeUtil.effectConfigs.get(n);
                                    if (zhuangBeiShuXing == null) {
                                        return false;
                                    } else {
                                        HashMap<Integer, Integer> hashMap = new HashMap();
                                        Map<Integer, ShuXing> map = zhuangBeiShuXing.GetERandom();
                                        Random random = new Random();
                                        int i1 = map.size();
                                        int i2 = random.nextInt(i1);
                                        int i3 = 0;

                                        for(Iterator var25 = map.entrySet().iterator(); var25.hasNext(); ++i3) {
                                            Map.Entry<Integer, ShuXing> entry = (Map.Entry)var25.next();
                                            ShuXing shuXing = (ShuXing)entry.getValue();
                                            int i6 = fire.pb.effect.Module.getInstance().getIdByName(shuXing.GetEffectName().trim());
                                            if (i2 == i3) {
                                                int i7 = this.getBaseEffectByConfig(shuXing.GetBodongMap());
                                                hashMap.put(i6, i7);
                                                i2 = random.nextInt(i1);
                                            }
                                        }

                                        this.SetExtraBaseAttr(hashMap, localEquipItemShuXing1);
                                        this.SetExtraAddAttr(localEquipItemShuXing1);
                                        localEquipItem.getEquipAttr().setTaozhuangeffectid(localEquipItem.getEquipAttr().getTaozhuangeffectid() + 1);
                                        int i21 = fire.pb.item.Module.getInstance().getEquipScore(localEquipItem);
                                        localEquipItem.getEquipAttr().setEquipscore(i21);
                                        if (i21 >= localEquipItem.getItemAttr().getTreasureScore()) {
                                            localEquipItem.getEquipAttr().setTreasure(1);
                                        } else {
                                            localEquipItem.getEquipAttr().setTreasure(0);
                                        }

                                        SAddItem localSAddItem = new SAddItem();
                                        localSAddItem.packid = localPack.getPackid();
                                        localSAddItem.data.add(ItemMaps.transItemData2SendData(localEquipItem.getDataItem(), this.equipKey, 0));
                                        psendWhileCommit(this.roleId, localSAddItem);
                                        Octets localOctets = localEquipItem.getTips();
                                        SGetItemTips localSGetItemTips = new SGetItemTips(1, localEquipItem.getKey(), localOctets);
                                        psendWhileCommit(this.roleId, localSGetItemTips);
                                        SDianhuaWeapon localObject1 = new SDianhuaWeapon();
                                        psendWhileCommit(this.roleId, localObject1);
                                        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleId));
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
                    logger.error("点化功能旧武器错误!!!");
                    return false;
                }
            }
        }
    }

    private int getBaseEffectByConfig(Map<Integer, BoDongDuan> paramMap) {
        ArrayList<Integer> arrayList = new ArrayList();
        Iterator var4 = paramMap.entrySet().iterator();

        while(var4.hasNext()) {
            Map.Entry<Integer, BoDongDuan> entry = (Map.Entry)var4.next();
            arrayList.add(((BoDongDuan)entry.getValue()).bodongduanbase);
        }

        BoDongDuan boDongDuan1 = (BoDongDuan)paramMap.get(0);
        BoDongDuan boDongDuan2 = (BoDongDuan)paramMap.get(paramMap.size() - 1);
        return boDongDuan2.max;
    }

    private ItemBase getItemKey(int itemId) {
        Iterator var3 = this.beibao.iterator();

        while(var3.hasNext()) {
            ItemBase item = (ItemBase)var3.next();
            if (itemId == item.getItemId()) {
                return item;
            }
        }

        return null;
    }

    public void SetExtraBaseAttr(Map<Integer, Integer> paramMap, EquipItemShuXing equipattr) {
        Pack localPack = new Pack(this.roleId, false);
        ItemBase bi = localPack.getItem(this.equipKey);
        EquipItem ei = (EquipItem)bi;
        Map<Integer, Integer> extraattr = ei.getEquipAttr().getExtraattr();
        Map<Integer, Integer> extraattr1 = ei.getEquipAttr().getAttr();
        Iterator var9 = paramMap.entrySet().iterator();

        while(var9.hasNext()) {
            Map.Entry<Integer, Integer> entry = (Map.Entry)var9.next();

            int key;
            int newaddvalue;
            for(Iterator var11 = paramMap.entrySet().iterator(); var11.hasNext(); extraattr.put(key, newaddvalue)) {
                Map.Entry<Integer, Integer> entry1 = (Map.Entry)var11.next();
                key = (Integer)entry.getKey();
                int key1 = (Integer)entry1.getKey();
                int extraattrvalue = 0;
                int extraattrvalue1 = 0;
                Random random = new Random();
                int i = random.nextInt(7);
                if (extraattr.get(key) != null) {
                    extraattrvalue = (Integer)extraattr.get(key);
                }

                if (extraattr1.get(key1) != null) {
                    extraattrvalue1 = (Integer)extraattr1.get(key1);
                }

                newaddvalue = extraattrvalue + i;
                int m = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(497).getValue());
                if (extraattrvalue >= m) {
                    newaddvalue = m;
                }
            }
        }

    }

    public void SetExtraAddAttr(EquipItemShuXing equipattr) {
        int cishu = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(606).getValue());
        Pack localPack = new Pack(this.roleId, false);
        ItemBase bi = localPack.getItem(this.equipKey);
        EquipItem ei = (EquipItem)bi;
        Map<Integer, Integer> addattr = ei.getEquipAttr().getAddattr();
        Map<Integer, Integer> extraaddattr = ei.getEquipAttr().getExtraaddattr();

        Integer integer;
        int extraddattrvalue;
        for(Iterator var9 = addattr.keySet().iterator(); var9.hasNext(); extraaddattr.put(integer, extraddattrvalue)) {
            integer = (Integer)var9.next();
            int randomnum = cishu;
            int curvalue = 0;
            if (extraaddattr.get(integer) != null) {
                curvalue = (Integer)extraaddattr.get(integer);
            }

            extraddattrvalue = curvalue + randomnum;
            int m = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(497).getValue());
            if (extraddattrvalue > m) {
                extraddattrvalue = m;
            }
        }

    }
}
