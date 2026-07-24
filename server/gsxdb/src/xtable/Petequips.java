package xtable;

// 类型化表访问入口
public class Petequips {
	Petequips() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().petequips.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.PetEquipItem value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.PetEquipItem get(Long key) {
		return _Tables_.getInstance().petequips.get(key);
	}

	public static xbean.PetEquipItem get(Long key, xbean.PetEquipItem value) {
		return _Tables_.getInstance().petequips.get(key, value);
	}

	public static void insert(Long key, xbean.PetEquipItem value) {
		_Tables_.getInstance().petequips.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().petequips.delete(key);
	}

	public static boolean add(Long key, xbean.PetEquipItem value) {
		return _Tables_.getInstance().petequips.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().petequips.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.PetEquipItem> getCache() {
		return _Tables_.getInstance().petequips.getCache();
	}

	public static mkdb.TTable<Long, xbean.PetEquipItem> getTable() {
		return _Tables_.getInstance().petequips;
	}

	public static xbean.PetEquipItem select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, xbean.PetEquipItem>() {
			public xbean.PetEquipItem get(xbean.PetEquipItem v) { return v.toData(); }
		});
	}

	public static Long selectId(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, Long>() {
				public Long get(xbean.PetEquipItem v) { return v.getId(); }
			});
	}

	public static Integer selectItemid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, Integer>() {
				public Integer get(xbean.PetEquipItem v) { return v.getItemid(); }
			});
	}

	public static Integer selectPos(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, Integer>() {
				public Integer get(xbean.PetEquipItem v) { return v.getPos(); }
			});
	}

	public static Integer selectTaozhuangid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, Integer>() {
				public Integer get(xbean.PetEquipItem v) { return v.getTaozhuangid(); }
			});
	}

	public static java.util.Map<Integer, Integer> selectPro(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, java.util.Map<Integer, Integer>>() {
				public java.util.Map<Integer, Integer> get(xbean.PetEquipItem v) { return v.getProAsData(); }
			});
	}

	public static java.util.Map<Integer, Integer> selectSkill(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.PetEquipItem, java.util.Map<Integer, Integer>>() {
				public java.util.Map<Integer, Integer> get(xbean.PetEquipItem v) { return v.getSkillAsData(); }
			});
	}

}
