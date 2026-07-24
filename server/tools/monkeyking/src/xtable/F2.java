package xtable;

// typed table access point
public class F2 {
	F2() {
	}

	public static xbean.fxbean get(String key) {
		return _Tables_.getInstance().f2.get(key);
	}

	public static xbean.fxbean get(String key, xbean.fxbean value) {
		return _Tables_.getInstance().f2.get(key, value);
	}

	public static void insert(String key, xbean.fxbean value) {
		_Tables_.getInstance().f2.insert(key, value);
	}

	public static void delete(String key) {
		_Tables_.getInstance().f2.delete(key);
	}

	public static boolean add(String key, xbean.fxbean value) {
		return _Tables_.getInstance().f2.add(key, value);
	}

	public static boolean remove(String key) {
		return _Tables_.getInstance().f2.remove(key);
	}

	public static mkdb.TTableCache<String, xbean.fxbean> getCache() {
		return _Tables_.getInstance().f2.getCache();
	}

	public static mkdb.TTable<String, xbean.fxbean> getTable() {
		return _Tables_.getInstance().f2;
	}

	public static xbean.fxbean select(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, xbean.fxbean>() {
			public xbean.fxbean get(xbean.fxbean v) { return v.toData(); }
		});
	}

	public static java.util.Set<Boolean> selectA(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, java.util.Set<Boolean>>() {
				public java.util.Set<Boolean> get(xbean.fxbean v) { return v.getAAsData(); }
			});
	}

	public static java.util.List<xbean.fcbean> selectB(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, java.util.List<xbean.fcbean>>() {
				public java.util.List<xbean.fcbean> get(xbean.fxbean v) { return v.getBAsData(); }
			});
	}

	public static java.util.List<Float> selectC(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, java.util.List<Float>>() {
				public java.util.List<Float> get(xbean.fxbean v) { return v.getCAsData(); }
			});
	}

	public static java.util.Map<Integer, xbean.fcbean> selectD(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, java.util.Map<Integer, xbean.fcbean>>() {
				public java.util.Map<Integer, xbean.fcbean> get(xbean.fxbean v) { return v.getDAsData(); }
			});
	}

	public static java.util.NavigableMap<String, Short> selectE(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, java.util.NavigableMap<String, Short>>() {
				public java.util.NavigableMap<String, Short> get(xbean.fxbean v) { return v.getEAsData(); }
			});
	}

	public static xbean.fxbean0 selectF(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, xbean.fxbean0>() {
				public xbean.fxbean0 get(xbean.fxbean v) { return v.getF(); }
			});
	}

	public static Integer selectG(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, Integer>() {
				public Integer get(xbean.fxbean v) { return v.getG(); }
			});
	}

	public static byte [] selectH(String key) {
		return getTable().select(key, new mkdb.TField<xbean.fxbean, byte []>() {
				public byte [] get(xbean.fxbean v) { return v.getHCopy(); }
			});
	}

}
