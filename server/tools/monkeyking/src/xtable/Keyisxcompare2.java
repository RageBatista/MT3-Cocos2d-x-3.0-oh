package xtable;

// typed table access point
public class Keyisxcompare2 {
	Keyisxcompare2() {
	}

	public static xbean.xbeanwithcbean get(xbean.xcompare2 key) {
		return _Tables_.getInstance().keyisxcompare2.get(key);
	}

	public static xbean.xbeanwithcbean get(xbean.xcompare2 key, xbean.xbeanwithcbean value) {
		return _Tables_.getInstance().keyisxcompare2.get(key, value);
	}

	public static void insert(xbean.xcompare2 key, xbean.xbeanwithcbean value) {
		_Tables_.getInstance().keyisxcompare2.insert(key, value);
	}

	public static void delete(xbean.xcompare2 key) {
		_Tables_.getInstance().keyisxcompare2.delete(key);
	}

	public static boolean add(xbean.xcompare2 key, xbean.xbeanwithcbean value) {
		return _Tables_.getInstance().keyisxcompare2.add(key, value);
	}

	public static boolean remove(xbean.xcompare2 key) {
		return _Tables_.getInstance().keyisxcompare2.remove(key);
	}

	public static mkdb.TTableCache<xbean.xcompare2, xbean.xbeanwithcbean> getCache() {
		return _Tables_.getInstance().keyisxcompare2.getCache();
	}

	public static mkdb.TTable<xbean.xcompare2, xbean.xbeanwithcbean> getTable() {
		return _Tables_.getInstance().keyisxcompare2;
	}

	public static xbean.xbeanwithcbean select(xbean.xcompare2 key) {
		return getTable().select(key, new mkdb.TField<xbean.xbeanwithcbean, xbean.xbeanwithcbean>() {
			public xbean.xbeanwithcbean get(xbean.xbeanwithcbean v) { return v.toData(); }
		});
	}

	public static xbean.xcompare selectXc1(xbean.xcompare2 key) {
		return getTable().select(key, new mkdb.TField<xbean.xbeanwithcbean, xbean.xcompare>() {
				public xbean.xcompare get(xbean.xbeanwithcbean v) { return v.getXc1(); }
			});
	}

	public static java.util.List<xbean.xcompare2> selectXc2(xbean.xcompare2 key) {
		return getTable().select(key, new mkdb.TField<xbean.xbeanwithcbean, java.util.List<xbean.xcompare2>>() {
				public java.util.List<xbean.xcompare2> get(xbean.xbeanwithcbean v) { return v.getXc2AsData(); }
			});
	}

	public static Float selectF(xbean.xcompare2 key) {
		return getTable().select(key, new mkdb.TField<xbean.xbeanwithcbean, Float>() {
				public Float get(xbean.xbeanwithcbean v) { return v.getF(); }
			});
	}

}
