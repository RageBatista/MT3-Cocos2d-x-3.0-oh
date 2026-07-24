package xtable;

// typed table access point
public class Ffloat {
	Ffloat() {
	}

	public static Integer get(Float key) {
		return _Tables_.getInstance().ffloat.get(key);
	}

	public static Integer get(Float key, Integer value) {
		return _Tables_.getInstance().ffloat.get(key, value);
	}

	public static void insert(Float key, Integer value) {
		_Tables_.getInstance().ffloat.insert(key, value);
	}

	public static void delete(Float key) {
		_Tables_.getInstance().ffloat.delete(key);
	}

	public static boolean add(Float key, Integer value) {
		return _Tables_.getInstance().ffloat.add(key, value);
	}

	public static boolean remove(Float key) {
		return _Tables_.getInstance().ffloat.remove(key);
	}

	public static mkdb.TTableCache<Float, Integer> getCache() {
		return _Tables_.getInstance().ffloat.getCache();
	}

	public static mkdb.TTable<Float, Integer> getTable() {
		return _Tables_.getInstance().ffloat;
	}

	public static Integer select(Float key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
