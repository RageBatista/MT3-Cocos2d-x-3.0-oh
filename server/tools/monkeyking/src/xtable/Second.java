package xtable;

// typed table access point
public class Second {
	Second() {
	}

	public static xbean.Second get(Integer key) {
		return _Tables_.getInstance().second.get(key);
	}

	public static xbean.Second get(Integer key, xbean.Second value) {
		return _Tables_.getInstance().second.get(key, value);
	}

	public static void insert(Integer key, xbean.Second value) {
		_Tables_.getInstance().second.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().second.delete(key);
	}

	public static boolean add(Integer key, xbean.Second value) {
		return _Tables_.getInstance().second.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().second.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.Second> getCache() {
		return _Tables_.getInstance().second.getCache();
	}

	public static mkdb.TTable<Integer, xbean.Second> getTable() {
		return _Tables_.getInstance().second;
	}

	public static xbean.Second select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, xbean.Second>() {
			public xbean.Second get(xbean.Second v) { return v.toData(); }
		});
	}

	public static java.util.Set<Integer> selectSetfirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.Second v) { return v.getSetfirstAsData(); }
			});
	}

	public static java.util.List<xbean.First> selectListfirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, java.util.List<xbean.First>>() {
				public java.util.List<xbean.First> get(xbean.Second v) { return v.getListfirstAsData(); }
			});
	}

	public static java.util.List<xbean.First> selectVectorfirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, java.util.List<xbean.First>>() {
				public java.util.List<xbean.First> get(xbean.Second v) { return v.getVectorfirstAsData(); }
			});
	}

	public static java.util.Map<Integer, xbean.First> selectMapfirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, java.util.Map<Integer, xbean.First>>() {
				public java.util.Map<Integer, xbean.First> get(xbean.Second v) { return v.getMapfirstAsData(); }
			});
	}

	public static java.util.Map<String, xbean.First> selectMapxfirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, java.util.Map<String, xbean.First>>() {
				public java.util.Map<String, xbean.First> get(xbean.Second v) { return v.getMapxfirstAsData(); }
			});
	}

	public static xbean.First selectFirst(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, xbean.First>() {
				public xbean.First get(xbean.Second v) { return v.getFirst(); }
			});
	}

	public static Integer selectI(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, Integer>() {
				public Integer get(xbean.Second v) { return v.getI(); }
			});
	}

	public static byte [] selectMarshal2(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Second, byte []>() {
				public byte [] get(xbean.Second v) { return v.getMarshal2Copy(); }
			});
	}

}
