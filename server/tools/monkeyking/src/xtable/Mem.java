package xtable;

// typed table access point
public class Mem {
	Mem() {
	}

	public static xbean.DataType get(Integer key) {
		return _Tables_.getInstance().mem.get(key);
	}

	public static xbean.DataType get(Integer key, xbean.DataType value) {
		return _Tables_.getInstance().mem.get(key, value);
	}

	public static void insert(Integer key, xbean.DataType value) {
		_Tables_.getInstance().mem.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().mem.delete(key);
	}

	public static boolean add(Integer key, xbean.DataType value) {
		return _Tables_.getInstance().mem.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().mem.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.DataType> getCache() {
		return _Tables_.getInstance().mem.getCache();
	}

	public static mkdb.TTable<Integer, xbean.DataType> getTable() {
		return _Tables_.getInstance().mem;
	}

	public static xbean.DataType select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, xbean.DataType>() {
			public xbean.DataType get(xbean.DataType v) { return v.toData(); }
		});
	}

	public static Integer selectId(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, Integer>() {
				public Integer get(xbean.DataType v) { return v.getId(); }
			});
	}

	public static Long selectMax(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, Long>() {
				public Long get(xbean.DataType v) { return v.getMax(); }
			});
	}

	public static Short selectMshort(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, Short>() {
				public Short get(xbean.DataType v) { return v.getMshort(); }
			});
	}

	public static Float selectMfloat(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, Float>() {
				public Float get(xbean.DataType v) { return v.getMfloat(); }
			});
	}

	public static String selectName(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, String>() {
				public String get(xbean.DataType v) { return v.getName(); }
			});
	}

	public static byte [] selectMobject(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, byte []>() {
				public byte [] get(xbean.DataType v) { return v.getMobjectCopy(); }
			});
	}

	public static xbean.SubBean selectSub(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, xbean.SubBean>() {
				public xbean.SubBean get(xbean.DataType v) { return v.getSub(); }
			});
	}

	public static java.util.Set<xbean.SubBean> selectSet(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, java.util.Set<xbean.SubBean>>() {
				public java.util.Set<xbean.SubBean> get(xbean.DataType v) { return v.getSetAsData(); }
			});
	}

	public static java.util.List<xbean.SubBean> selectList(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, java.util.List<xbean.SubBean>>() {
				public java.util.List<xbean.SubBean> get(xbean.DataType v) { return v.getListAsData(); }
			});
	}

	public static java.util.Map<String, xbean.SubBean> selectMap(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.DataType, java.util.Map<String, xbean.SubBean>>() {
				public java.util.Map<String, xbean.SubBean> get(xbean.DataType v) { return v.getMapAsData(); }
			});
	}

}
