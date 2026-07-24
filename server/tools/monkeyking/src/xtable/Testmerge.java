package xtable;

// typed table access point
public class Testmerge {
	Testmerge() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().testmerge.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.RBTest value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.RBTest get(Long key) {
		return _Tables_.getInstance().testmerge.get(key);
	}

	public static xbean.RBTest get(Long key, xbean.RBTest value) {
		return _Tables_.getInstance().testmerge.get(key, value);
	}

	public static void insert(Long key, xbean.RBTest value) {
		_Tables_.getInstance().testmerge.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().testmerge.delete(key);
	}

	public static boolean add(Long key, xbean.RBTest value) {
		return _Tables_.getInstance().testmerge.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().testmerge.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.RBTest> getCache() {
		return _Tables_.getInstance().testmerge.getCache();
	}

	public static mkdb.TTable<Long, xbean.RBTest> getTable() {
		return _Tables_.getInstance().testmerge;
	}

	public static xbean.RBTest select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, xbean.RBTest>() {
			public xbean.RBTest get(xbean.RBTest v) { return v.toData(); }
		});
	}

	public static Integer selectI(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, Integer>() {
				public Integer get(xbean.RBTest v) { return v.getI(); }
			});
	}

	public static xbean.RB selectRb(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, xbean.RB>() {
				public xbean.RB get(xbean.RBTest v) { return v.getRb(); }
			});
	}

	public static java.util.Set<xbean.RB> selectSet(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, java.util.Set<xbean.RB>>() {
				public java.util.Set<xbean.RB> get(xbean.RBTest v) { return v.getSetAsData(); }
			});
	}

	public static java.util.List<xbean.RB> selectList(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, java.util.List<xbean.RB>>() {
				public java.util.List<xbean.RB> get(xbean.RBTest v) { return v.getListAsData(); }
			});
	}

	public static java.util.Map<Integer, xbean.RB> selectMap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, java.util.Map<Integer, xbean.RB>>() {
				public java.util.Map<Integer, xbean.RB> get(xbean.RBTest v) { return v.getMapAsData(); }
			});
	}

	public static java.util.NavigableMap<Integer, xbean.RB> selectTree(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.RBTest, java.util.NavigableMap<Integer, xbean.RB>>() {
				public java.util.NavigableMap<Integer, xbean.RB> get(xbean.RBTest v) { return v.getTreeAsData(); }
			});
	}

}
