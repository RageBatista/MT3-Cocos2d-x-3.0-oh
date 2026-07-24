package xtable;

// typed table access point
public class Flush3 {
	Flush3() {
	}

	public static xbean.Flush get(Integer key) {
		return _Tables_.getInstance().flush3.get(key);
	}

	public static xbean.Flush get(Integer key, xbean.Flush value) {
		return _Tables_.getInstance().flush3.get(key, value);
	}

	public static void insert(Integer key, xbean.Flush value) {
		_Tables_.getInstance().flush3.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().flush3.delete(key);
	}

	public static boolean add(Integer key, xbean.Flush value) {
		return _Tables_.getInstance().flush3.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().flush3.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.Flush> getCache() {
		return _Tables_.getInstance().flush3.getCache();
	}

	public static mkdb.TTable<Integer, xbean.Flush> getTable() {
		return _Tables_.getInstance().flush3;
	}

	public static xbean.Flush select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Flush, xbean.Flush>() {
			public xbean.Flush get(xbean.Flush v) { return v.toData(); }
		});
	}

	public static Long selectCountlong(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Flush, Long>() {
				public Long get(xbean.Flush v) { return v.getCountlong(); }
			});
	}

	public static Float selectBusy(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Flush, Float>() {
				public Float get(xbean.Flush v) { return v.getBusy(); }
			});
	}

	public static xbean.Family selectDummy(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Flush, xbean.Family>() {
				public xbean.Family get(xbean.Flush v) { return v.getDummy(); }
			});
	}

}
