package xtable;

// typed table access point
public class Family {
	Family() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().family.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.Family value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.Family get(Long key) {
		return _Tables_.getInstance().family.get(key);
	}

	public static xbean.Family get(Long key, xbean.Family value) {
		return _Tables_.getInstance().family.get(key, value);
	}

	public static void insert(Long key, xbean.Family value) {
		_Tables_.getInstance().family.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().family.delete(key);
	}

	public static boolean add(Long key, xbean.Family value) {
		return _Tables_.getInstance().family.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().family.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.Family> getCache() {
		return _Tables_.getInstance().family.getCache();
	}

	public static mkdb.TTable<Long, xbean.Family> getTable() {
		return _Tables_.getInstance().family;
	}

	public static xbean.Family select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, xbean.Family>() {
			public xbean.Family get(xbean.Family v) { return v.toData(); }
		});
	}

	public static Integer selectId(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getId(); }
			});
	}

	public static Integer selectLevel(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getLevel(); }
			});
	}

	public static Integer selectContribution(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getContribution(); }
			});
	}

	public static Integer selectLeaderid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getLeaderid(); }
			});
	}

	public static Integer selectCreatorid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getCreatorid(); }
			});
	}

	public static String selectName(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getName(); }
			});
	}

	public static String selectAim(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getAim(); }
			});
	}

	public static String selectPub(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getPub(); }
			});
	}

	public static java.util.Map<Integer, xbean.MemberInfo> selectMemebers(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, java.util.Map<Integer, xbean.MemberInfo>>() {
				public java.util.Map<Integer, xbean.MemberInfo> get(xbean.Family v) { return v.getMemebersAsData(); }
			});
	}

	public static Integer selectStatus(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getStatus(); }
			});
	}

	public static Long selectCreate_time(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Long>() {
				public Long get(xbean.Family v) { return v.getCreate_time(); }
			});
	}

	public static Integer selectWell_known(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getWell_known(); }
			});
	}

}
