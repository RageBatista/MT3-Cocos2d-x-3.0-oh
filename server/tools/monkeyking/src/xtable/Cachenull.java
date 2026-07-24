package xtable;

// typed table access point
public class Cachenull {
	Cachenull() {
	}

	public static xbean.Family get(Integer key) {
		return _Tables_.getInstance().cachenull.get(key);
	}

	public static xbean.Family get(Integer key, xbean.Family value) {
		return _Tables_.getInstance().cachenull.get(key, value);
	}

	public static void insert(Integer key, xbean.Family value) {
		_Tables_.getInstance().cachenull.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().cachenull.delete(key);
	}

	public static boolean add(Integer key, xbean.Family value) {
		return _Tables_.getInstance().cachenull.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().cachenull.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.Family> getCache() {
		return _Tables_.getInstance().cachenull.getCache();
	}

	public static mkdb.TTable<Integer, xbean.Family> getTable() {
		return _Tables_.getInstance().cachenull;
	}

	public static xbean.Family select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, xbean.Family>() {
			public xbean.Family get(xbean.Family v) { return v.toData(); }
		});
	}

	public static Integer selectId(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getId(); }
			});
	}

	public static Integer selectLevel(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getLevel(); }
			});
	}

	public static Integer selectContribution(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getContribution(); }
			});
	}

	public static Integer selectLeaderid(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getLeaderid(); }
			});
	}

	public static Integer selectCreatorid(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getCreatorid(); }
			});
	}

	public static String selectName(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getName(); }
			});
	}

	public static String selectAim(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getAim(); }
			});
	}

	public static String selectPub(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, String>() {
				public String get(xbean.Family v) { return v.getPub(); }
			});
	}

	public static java.util.Map<Integer, xbean.MemberInfo> selectMemebers(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, java.util.Map<Integer, xbean.MemberInfo>>() {
				public java.util.Map<Integer, xbean.MemberInfo> get(xbean.Family v) { return v.getMemebersAsData(); }
			});
	}

	public static Integer selectStatus(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getStatus(); }
			});
	}

	public static Long selectCreate_time(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Long>() {
				public Long get(xbean.Family v) { return v.getCreate_time(); }
			});
	}

	public static Integer selectWell_known(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Family, Integer>() {
				public Integer get(xbean.Family v) { return v.getWell_known(); }
			});
	}

}
