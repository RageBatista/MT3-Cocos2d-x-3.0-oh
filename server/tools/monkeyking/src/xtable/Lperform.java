package xtable;

// typed table access point
public class Lperform {
	Lperform() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().lperform.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.TestLP value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.TestLP get(Long key) {
		return _Tables_.getInstance().lperform.get(key);
	}

	public static xbean.TestLP get(Long key, xbean.TestLP value) {
		return _Tables_.getInstance().lperform.get(key, value);
	}

	public static void insert(Long key, xbean.TestLP value) {
		_Tables_.getInstance().lperform.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().lperform.delete(key);
	}

	public static boolean add(Long key, xbean.TestLP value) {
		return _Tables_.getInstance().lperform.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().lperform.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.TestLP> getCache() {
		return _Tables_.getInstance().lperform.getCache();
	}

	public static mkdb.TTable<Long, xbean.TestLP> getTable() {
		return _Tables_.getInstance().lperform;
	}

	public static xbean.TestLP select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, xbean.TestLP>() {
			public xbean.TestLP get(xbean.TestLP v) { return v.toData(); }
		});
	}

	public static Integer selectI(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, Integer>() {
				public Integer get(xbean.TestLP v) { return v.getI(); }
			});
	}

	public static java.util.Set<Integer> selectSet1(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.TestLP v) { return v.getSet1AsData(); }
			});
	}

	public static java.util.Map<Integer, Integer> selectMap1(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, java.util.Map<Integer, Integer>>() {
				public java.util.Map<Integer, Integer> get(xbean.TestLP v) { return v.getMap1AsData(); }
			});
	}

	public static java.util.List<Integer> selectList1(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, java.util.List<Integer>>() {
				public java.util.List<Integer> get(xbean.TestLP v) { return v.getList1AsData(); }
			});
	}

	public static java.util.Map<Integer, xbean.RB> selectMap2(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, java.util.Map<Integer, xbean.RB>>() {
				public java.util.Map<Integer, xbean.RB> get(xbean.TestLP v) { return v.getMap2AsData(); }
			});
	}

	public static java.util.List<xbean.RB> selectList2(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestLP, java.util.List<xbean.RB>>() {
				public java.util.List<xbean.RB> get(xbean.TestLP v) { return v.getList2AsData(); }
			});
	}

}
