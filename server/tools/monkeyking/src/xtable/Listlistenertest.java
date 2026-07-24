package xtable;

// typed table access point
public class Listlistenertest {
	Listlistenertest() {
	}

	public static xbean.ListListenerTestEffects get(Long key) {
		return _Tables_.getInstance().listlistenertest.get(key);
	}

	public static xbean.ListListenerTestEffects get(Long key, xbean.ListListenerTestEffects value) {
		return _Tables_.getInstance().listlistenertest.get(key, value);
	}

	public static void insert(Long key, xbean.ListListenerTestEffects value) {
		_Tables_.getInstance().listlistenertest.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().listlistenertest.delete(key);
	}

	public static boolean add(Long key, xbean.ListListenerTestEffects value) {
		return _Tables_.getInstance().listlistenertest.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().listlistenertest.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.ListListenerTestEffects> getCache() {
		return _Tables_.getInstance().listlistenertest.getCache();
	}

	public static mkdb.TTable<Long, xbean.ListListenerTestEffects> getTable() {
		return _Tables_.getInstance().listlistenertest;
	}

	public static xbean.ListListenerTestEffects select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.ListListenerTestEffects, xbean.ListListenerTestEffects>() {
			public xbean.ListListenerTestEffects get(xbean.ListListenerTestEffects v) { return v.toData(); }
		});
	}

	public static java.util.List<xbean.ListListenerTestEffect> selectEffects(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.ListListenerTestEffects, java.util.List<xbean.ListListenerTestEffect>>() {
				public java.util.List<xbean.ListListenerTestEffect> get(xbean.ListListenerTestEffects v) { return v.getEffectsAsData(); }
			});
	}

}
