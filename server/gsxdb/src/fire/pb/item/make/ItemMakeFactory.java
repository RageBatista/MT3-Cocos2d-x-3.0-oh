package fire.pb.item.make;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;

import org.apache.log4j.Logger;

import fire.pb.RoleConfigManager;
import fire.pb.item.EquipDoubleInfo;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.NewShuangJiaInfo;
import fire.pb.item.PetEquipItem;
import fire.pb.item.PetEquipItemShuXing;
import fire.pb.item.SEquipAddattributelib;
import fire.pb.item.SEquipAddattributerandomlib;
import fire.pb.item.SPetEquiptaozhuang;
import fire.pb.item.SRonglianAttrLimit;
import fire.pb.main.ConfigManager;
import fire.pb.product.Commontext;
import fire.pb.util.Misc;
import fire.util.ExceptionHandler;

public class ItemMakeFactory {

	private static ItemMakeFactory _Instance;
	private static final Random RANDOM = new Random();

	private ItemMakeFactory() {
	}

	Logger logger = Logger.getLogger("ITEM");

	public synchronized static ItemMakeFactory getFactory() {
		if (_Instance == null)
			_Instance = new ItemMakeFactory();

		return _Instance;
	}

	// 安全整数解析工具方法
	private static int safeParseInt(String value, int defaultValue) {
		try {
			return Integer.parseInt(value);
		} catch (NumberFormatException e) {
			Logger.getLogger("ITEM").error("Invalid number format: " + value, e);
			return defaultValue;
		}
	}

	public EquipItem genItemMakeByWay(int equipId, String producer) {
		EquipItem equipItem = (EquipItem) Module.getInstance().getItemManager()
				.genItemBase(equipId, 1, 0, null, false);

		if (null == equipItem) {
			logger.error("装备id:" + equipId + "装备配置为空");
			return null;
		}

		// 基本属性
		equipItem.getEquipAttr().setProducer(producer);
		equipItem.setEquipEndure();

		return equipItem;
	}

	public void genItem(EquipItem equipItem) {
		// 处理双加属性
		setEquipBaseInfo(equipItem);
		// 处理特技，特效
		setEquipSkillAndEffect(equipItem);
	}

	public void genSkillAndEffect(EquipItem paramEquipItem) {
		this.setEquipSkillAndEffect(paramEquipItem);
	}

	public void genItemWithSkillAndShuangJia(EquipItem paramEquipItem) {
		this.setEquipSkillAndEffect(paramEquipItem);
	}

	public void genItemWithSkillAndShuangJia2(long roleid, EquipItem equipItem) {
		this.genItemWithSkillAndShuangJia(equipItem);
		this.setEquipNewShuangJia(roleid, equipItem);
	}

	// 兼容旧版本的调用
	public void genItemWithSkillAndShuangJia2(EquipItem equipItem) {
		genItem(equipItem);
	}

	public void genPetEquip(PetEquipItem equipItem) {
		if (equipItem == null) {
			return;
		}
		PetEquipItemShuXing attr = equipItem.getItemAttr();
		if (attr == null) {
			return;
		}

		Map<Integer, Integer> pros = splitPro(attr.getPro(), attr.getMin(), attr.getMax());
		if (pros != null) {
			equipItem.Setpro(pros);
		}

		Map<Integer, Integer> skills = splitSkill(attr.getSkill(), 0);
		if (skills != null) {
			equipItem.Setskill(skills);
		}

		equipItem.getEquipAttr().setPos(attr.getPos());

		// 宠物装备套装功能
		Map<Integer, SPetEquiptaozhuang> taozhuangid = ConfigManager.getInstance().getConf(SPetEquiptaozhuang.class);
		if (taozhuangid != null) {
			for (SPetEquiptaozhuang pc : taozhuangid.values()) {
				SPetEquiptaozhuang taozhuang = taozhuangid.get(pc.getId());
				double jilv = (double) taozhuang.jilv / 100.0;
				double dzjilv = (double) taozhuang.dzjilv / 100.0;
				if (Math.random() < dzjilv && Math.random() < jilv) {
					equipItem.setTaozhuangid(pc.getSkill());
				}
			}
		}
	}

	public void setEquipNewShuangJia(Long roleid, EquipItem equipItem) {
		if (equipItem.getItemAttr().doubleaddlimit != null && !equipItem.getItemAttr().doubleaddlimit.isEmpty()) {
			NewShuangJiaInfo equipDoubleInfo = EquipDoubleInfo.getEquipDoubleInfo(roleid, equipItem.getUniqId());
			if (equipDoubleInfo != null && equipDoubleInfo.lockstate) {
				// 已锁定的属性，增加值
				for (Integer id : equipDoubleInfo.lockedProp) {
					SRonglianAttrLimit sRonglianAttrLimit = (SRonglianAttrLimit) ConfigManager.getInstance().getConf(SRonglianAttrLimit.class).get(id);
					if (sRonglianAttrLimit != null) {
						if (equipDoubleInfo.doubleadd.containsKey(sRonglianAttrLimit.proptype)) {
							int value = equipDoubleInfo.doubleadd.get(sRonglianAttrLimit.proptype);
							if (value == sRonglianAttrLimit.maxvalue) {
								continue;
							}
						}

						int val = equipDoubleInfo.doubleadd.get(sRonglianAttrLimit.proptype) + this.getNewShuangJiaAddValue();
						if (val < sRonglianAttrLimit.minvalue) {
							val = sRonglianAttrLimit.minvalue;
						}

						if (val > sRonglianAttrLimit.maxvalue) {
							val = sRonglianAttrLimit.maxvalue;
						}

						equipDoubleInfo.doubleadd.put(sRonglianAttrLimit.proptype, val);
					}
				}
			} else {
				// 新随机双加属性
				EquipItemShuXing equipItemShuXing = equipItem.getItemAttr();
				int i = Misc.getRandomBetween(1, 10000);
				if (i < equipItemShuXing.addAttrRate) {
					int random = Misc.getRandomBetween(1, 2);
					List<Integer> props = new ArrayList();
					String[] ids = equipItem.getItemAttr().doubleaddlimit.split(",");

					for (String id : ids) {
						SRonglianAttrLimit sRonglianAttrLimit = (SRonglianAttrLimit) ConfigManager.getInstance().getConf(SRonglianAttrLimit.class).get(Integer.valueOf(id));
						if (sRonglianAttrLimit != null) {
							props.add(Integer.valueOf(id));
						}
					}

					if (equipDoubleInfo != null) {
						equipDoubleInfo.doubleadd.clear();
						equipDoubleInfo.lockedProp.clear();
					} else {
						equipDoubleInfo = new NewShuangJiaInfo();
						equipDoubleInfo.lockstate = false;
						equipDoubleInfo.uniId = equipItem.getUniqId();
					}

					List<Integer> added = new ArrayList();

					for (int count = 0; count < random; ++count) {
						int index = Misc.getRandomBetween(0, props.size() - 1);
						if (!added.contains(index)) {
							SRonglianAttrLimit sRonglianAttrLimit = (SRonglianAttrLimit) ConfigManager.getInstance().getConf(SRonglianAttrLimit.class).get(props.get(index));
							if (sRonglianAttrLimit != null) {
								int val = this.getNewShuangJiaAddValue();
								if (val == 0) {
									val = 1;
								}

								if (val < sRonglianAttrLimit.minvalue) {
									val = sRonglianAttrLimit.minvalue;
								}

								if (val > sRonglianAttrLimit.maxvalue) {
									val = sRonglianAttrLimit.minvalue;
								}

								equipDoubleInfo.doubleadd.put(sRonglianAttrLimit.proptype, val);
								equipDoubleInfo.lockedProp.add(props.get(index));
							}
						}
					}
				}
			}

			HashMap<Long, NewShuangJiaInfo> equipAllInfo = EquipDoubleInfo.getEquipAllInfo(roleid);
			if (equipAllInfo == null) {
				equipAllInfo = new HashMap();
			}

			equipAllInfo.put(equipItem.getUniqId(), equipDoubleInfo);
			EquipDoubleInfo.UpdateEquipInfo(roleid, equipAllInfo);
		}
	}

	// 双加属性刷新（洗练）
	public void setEquipShuangJiaInfo(EquipItem paramEquipItem) {
		try {
			EquipItemShuXing equipItemShuXing = paramEquipItem.getItemAttr();
			int i = Misc.getRandomBetween(1, 10000);
			if (i < equipItemShuXing.addAttrRate) {
				if (equipItemShuXing.getAddAttrInfo() == null) {
					return;
				}

				int maxIndex = equipItemShuXing.getAddAttrInfo().size() - 1;
				int j = Misc.getRandomBetween(0, maxIndex);
				String[] arrayOfString = ((String) equipItemShuXing.getAddAttrInfo().get(j)).split(";");
				Map<Integer, Integer> map = this.getAddEffectByConfig(arrayOfString);
				paramEquipItem.getEquipAttr().getAddattr().clear();
				paramEquipItem.getEquipAttr().getAddattrAsData().clear();
				paramEquipItem.SetAddAttr(map);
			}
		} catch (Exception exception) {
			this.logger.error("Failed to set equip shuangjia info for item " + paramEquipItem.getItemId(), exception);
		}
	}

	// 计算双加加成值
	public int getNewShuangJiaAddValue() {
		int rnd = Misc.getRandomBetween(1, 2);
		Integer ronglian = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(607).value);
		if (Misc.getRandomBetween(1, 100) < ronglian) {
			rnd = -1;
		}

		return rnd;
	}

	public Map<Integer, Integer> splitPro(String pro, String min, String max) {
		Map<Integer, Integer> result = new HashMap<Integer, Integer>();
		if (pro == null || pro.isEmpty()) {
			return result;
		}
		String[] pros = pro.split(",");
		String[] mins = min == null ? new String[0] : min.split(",");
		String[] maxs = max == null ? new String[0] : max.split(",");

		for (int i = 0; i < pros.length; i++) {
			int propId;
			try {
				propId = Integer.parseInt(pros[i].trim());
			} catch (Exception e) {
				continue;
			}

			int minVal = 0;
			int maxVal = 0;
			if (i < mins.length) {
				try {
					minVal = Integer.parseInt(mins[i].trim());
				} catch (Exception e) {
				}
			}
			if (i < maxs.length) {
				try {
					maxVal = Integer.parseInt(maxs[i].trim());
				} catch (Exception e) {
				}
			}
			if (minVal > maxVal) {
				int tmp = minVal;
				minVal = maxVal;
				maxVal = tmp;
			}

			int value = (minVal == maxVal) ? minVal : Misc.getRandomBetween(minVal, maxVal);
			result.put(propId, value);
		}
		return result;
	}

	public Map<Integer, Integer> splitSkill(String skill, int count) {
		Map<Integer, Integer> result = new HashMap<Integer, Integer>();
		if (skill == null || skill.isEmpty()) {
			return result;
		}

		String[] skills = skill.split(",");
		List<Integer> pool = new ArrayList<Integer>();
		for (String s : skills) {
			if (s == null) {
				continue;
			}
			try {
				int id = Integer.parseInt(s.trim());
				if (id > 0 && !pool.contains(id)) {
					pool.add(id);
				}
			} catch (Exception e) {
			}
		}

		if (pool.isEmpty()) {
			return result;
		}

		if (count <= 0 || count >= pool.size()) {
			for (Integer id : pool) {
				result.put(id, 0);
			}
			return result;
		}

		for (int i = 0; i < count; i++) {
			int idx = Misc.getRandomBetween(0, pool.size() - 1);
			Integer id = pool.remove(idx);
			result.put(id, 0);
		}
		return result;
	}

	private void setEquipBaseInfo(EquipItem equip) {

		try {
			// 处理基础属性
			EquipItemShuXing attr = equip.getItemAttr();
			int BaseEffectId = attr.getBaseAttrId();
			// 从ItemMakeUtil.effectConfigs 中获取基础装备的属性
			ZhuangBeiShuXing equipAttrCnf = ItemMakeUtil.effectConfigs
					.get(BaseEffectId);
			if (equipAttrCnf == null) {
				return;
			}

			Map<Integer, Integer> baseAttrs = new HashMap<Integer, Integer>();
			Map<Integer, ShuXing> erandomMap = equipAttrCnf.GetERandom();
			for (Entry<Integer, ShuXing> shuxing : erandomMap.entrySet()) {
				ShuXing sx = shuxing.getValue();
				int effectid = 0;
				try {
					effectid = fire.pb.effect.Module.getInstance()
							.getIdByName(sx.GetEffectName().trim());
				} finally {
				}
				int errectvalue = getBaseEffectByConfig(sx.GetBodongMap());
				baseAttrs.put(effectid, errectvalue);
			}

			equip.SetBaseAttr(baseAttrs);

			// 处理附加属性
			int randomval = Misc.getRandomBetween(1,
					Commontext.EQUIP_EFFECT_RATE_BASE);
			if (randomval < attr.addAttrRate) { // 随机到有附加属性
				if (attr.getAddAttrInfo() == null || attr.getAddAttrInfo().isEmpty())
					return;
				// 随机加哪种附加属性 1双加 2单加 3一加一减
				int attIndex = Misc.getRandomBetween(0, attr.getAddAttrInfo().size() - 1);
				String[] AddEffectIds = attr.getAddAttrInfo().get(attIndex)
						.split(";");
				Map<Integer, Integer> addeffects = getAddEffectByConfig(AddEffectIds);

				equip.SetAddAttr(addeffects);
			}
		} catch (Exception e) {
			ExceptionHandler.handle(e, "ItemMakeFactory");
		}
	}

	private void setEquipSkillAndEffect(EquipItem equipItem) {
		try {
			// 处理技能和特效
			EquipItemShuXing attr = equipItem.getItemAttr();
			if (attr == null)
				return;

			int effectid = attr.getRandomEffectId();
			if (effectid > 0) {
				SEquipAddattributerandomlib addMap = ItemMakeUtil.EQUIPADDRANDOM_CFGS
						.get(effectid);
				if (addMap == null)
					return;
				int texiaoid = getSkillAndEffectByConfig(addMap);
				if (texiaoid > 0)
					equipItem.getEquipAttr().setEffect(texiaoid);
			}

			int skillid = attr.getRandomSkillId();
			if (skillid > 0) {
				SEquipAddattributerandomlib addMap = ItemMakeUtil.EQUIPADDRANDOM_CFGS
						.get(skillid);
				if (addMap == null)
					return;
				int jinengid = getSkillAndEffectByConfig(addMap);
				if (jinengid > 0)
					equipItem.getEquipAttr().setSkill(jinengid);
			}

			int neweffectid = attr.getRandomNewEffectId();
			if (neweffectid > 0) {
				SEquipAddattributerandomlib addMap = ItemMakeUtil.EQUIPADDRANDOM_CFGS.get(neweffectid);
				if (addMap == null)
					return;
				int texiaoid = getSkillAndEffectByConfig(addMap);
				if (texiaoid > 0)
					equipItem.getEquipAttr().setNewskill(texiaoid);
			}
		} catch (Exception e) {
			ExceptionHandler.handle(e, "ItemMakeFactory");
		}
	}

	private int getBaseEffectByConfig(Map<Integer, BoDongDuan> bodongMaps) {
		// 先随机在哪个波动段
		List<Integer> quanzhongList = new ArrayList<Integer>();
		for (Entry<Integer, BoDongDuan> bdMap : bodongMaps.entrySet()) {
			quanzhongList.add(bdMap.getValue().bodongduanbase);
		}

		int resultIndex = Misc.getProbability(quanzhongList);
		if (resultIndex >= bodongMaps.size())
			return 0;

		BoDongDuan bdduan = bodongMaps.get(resultIndex);

		// 随机出该波动段的值
		int value = Misc.getRandomBetween(bdduan.min, bdduan.max);
		if (value > 0)
			return value;

		return 0;
	}

	private Map<Integer, Integer> getAddEffectByConfig(String[] attrIds) {

		Map<Integer, Integer> addeffects = new HashMap<Integer, Integer>();
		ArrayList<String> addname = new ArrayList<String>();

		for (String attrid : attrIds) {
			ArrayList<Integer> addindex = new ArrayList<Integer>();
			ArrayList<Integer> addquanzhong = new ArrayList<Integer>();

			FujiaShuXingXinXi addShuxing = ItemMakeUtil.fujiaShuXingConfigs
					.get(Integer.parseInt(attrid));

			for (int i = 0; i < addShuxing.addtableId.size(); i++) {
				if (addShuxing.addtableId.get(i) > 0) {
					if (i > addShuxing.addname.size())
						continue;

					String name = addShuxing.addname.get(i);
					if (!addname.contains(name)) { // 控制不能随机到相同的属性ID
						addindex.add(addShuxing.addtableId.get(i));
						addquanzhong.add(addShuxing.addquanzhong.get(i));
					}
				}
			}

			int resultIndex = Misc.getProbability(addquanzhong);
			if (resultIndex >= addquanzhong.size())
				return null;

			// 得到属性的ID
			int value = addindex.get(resultIndex);
			if (value > 0) {
				SEquipAddattributelib equipAdd = ItemMakeUtil.EQUIPADDATTR_CFGS
						.get(value);
				String qujian[] = equipAdd.attributeidinterval.split(";");
				int effectid = fire.pb.effect.Module.getInstance()
						.getIdByName(equipAdd.attributename.trim());
				int effiectvalue = Misc.getRandomBetween(
						Integer.parseInt(qujian[0]),
						Integer.parseInt(qujian[1]));

				addeffects.put(effectid, effiectvalue);

				addname.add(equipAdd.attributename.trim());

			}

		}
		return addeffects;
	}

	private int getSkillAndEffectByConfig(SEquipAddattributerandomlib addMap) {

		int resultIndex = Misc.getProbabilityByBase(
				addMap.addattributerquanzhong, addMap.allquanzhong);
		if (resultIndex >= addMap.addattributer.size() || resultIndex == -1)
			return 0;

		int value = addMap.addattributer.get(resultIndex);
		if (value > 0) {
			SEquipAddattributelib equipAdd = ItemMakeUtil.EQUIPADDATTR_CFGS
					.get(value);
			if (equipAdd != null) {
				return equipAdd.getSkillid();
			}
		}

		return 0;
	}
}
