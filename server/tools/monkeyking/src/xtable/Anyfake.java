package xtable;

// typed table access point
public class Anyfake {
	Anyfake() {
	}

	public static xbean.AnyFake get(Integer key) {
		return _Tables_.getInstance().anyfake.get(key);
	}

	public static xbean.AnyFake get(Integer key, xbean.AnyFake value) {
		return _Tables_.getInstance().anyfake.get(key, value);
	}

	public static void insert(Integer key, xbean.AnyFake value) {
		_Tables_.getInstance().anyfake.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().anyfake.delete(key);
	}

	public static boolean add(Integer key, xbean.AnyFake value) {
		return _Tables_.getInstance().anyfake.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().anyfake.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.AnyFake> getCache() {
		return _Tables_.getInstance().anyfake.getCache();
	}

	public static mkdb.TTable<Integer, xbean.AnyFake> getTable() {
		return _Tables_.getInstance().anyfake;
	}

	public static xbean.AnyFake select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.AnyFake, xbean.AnyFake>() {
			public xbean.AnyFake get(xbean.AnyFake v) { return v.toData(); }
		});
	}

	public static Integer selectFake(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.AnyFake, Integer>() {
				public Integer get(xbean.AnyFake v) { return v.getFake(); }
			});
	}

}
