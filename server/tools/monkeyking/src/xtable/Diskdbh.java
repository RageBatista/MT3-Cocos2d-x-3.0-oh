package xtable;

// typed table access point
public class Diskdbh {
	Diskdbh() {
	}

	public static xbean.Diskdbh get(Long key) {
		return _Tables_.getInstance().diskdbh.get(key);
	}

	public static xbean.Diskdbh get(Long key, xbean.Diskdbh value) {
		return _Tables_.getInstance().diskdbh.get(key, value);
	}

	public static void insert(Long key, xbean.Diskdbh value) {
		_Tables_.getInstance().diskdbh.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().diskdbh.delete(key);
	}

	public static boolean add(Long key, xbean.Diskdbh value) {
		return _Tables_.getInstance().diskdbh.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().diskdbh.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.Diskdbh> getCache() {
		return _Tables_.getInstance().diskdbh.getCache();
	}

	public static mkdb.TTable<Long, xbean.Diskdbh> getTable() {
		return _Tables_.getInstance().diskdbh;
	}

	public static xbean.Diskdbh select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Diskdbh, xbean.Diskdbh>() {
			public xbean.Diskdbh get(xbean.Diskdbh v) { return v.toData(); }
		});
	}

	public static byte [] selectData(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Diskdbh, byte []>() {
				public byte [] get(xbean.Diskdbh v) { return v.getDataCopy(); }
			});
	}

}
