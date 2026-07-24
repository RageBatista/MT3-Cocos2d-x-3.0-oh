package xcache;

// 用户指定的cache名字作为最外层类的名字。cache的访问入口。
public class Mycache3 {
	////////////////////////////////////////////////////////////////
	// define cached valuetype
	public static class Valuetype {
		// define valuetype
		private volatile T4cache t4cache;

		public T4cache getT4cache() {
			return t4cache;
		}


		// declare valuetype
		public static class T4cache {
			T4cache() {
			}

			private volatile int i;
			private volatile java.util.Set<Integer> seti;
			private volatile byte [] marshal;
			private volatile xbean.Cacheb1 cacheb1;

			public int getI() {
				return i;
			}

			public java.util.Set<Integer> getSeti() {
				return seti;
			}

			public byte [] getMarshal() {
				return marshal;
			}

			public xbean.Cacheb1 getCacheb1() {
				return cacheb1;
			}

		}

	}

	///////////////////////////////////////////////////////////////
	// cache define
	// 外层公开的接口，得到的是Cache类型是基类的。基类只公开get和existInCache(不是必要的)。
	public static mkdb.util.ConcurrentCache<Long, Valuetype> getCache() {
		return CacheImpl.instance;
	}

	public static Valuetype get(Long key) {
		return CacheImpl.instance.get(key);
	}

	public static class CacheImpl extends mkdb.util.ConcurrentCache<Long, Valuetype> {
		CacheImpl() {
			super("mycache3");
		}

		// 暂时先不公开。需要的时候在基类添加接口并调整这里代码。
		// @Override
		mkdb.Lockey[] realGetLocks(Long key) {
			return new mkdb.Lockey[]{
					mkdb.Lockeys.get(xtable.T4cache.getTable(), key),
			};
		}

		private static class RealGet extends mkdb.Procedure {
			private mkdb.Lockey[] locks;
			private Long key;
			private Valuetype value = new Valuetype();
			
			@Override
			protected boolean process() throws Exception {
				// 先把记录锁排序并锁上，减少死锁可能。
				mkdb.Lockeys.lock(locks);

				value.t4cache = deepcopy(xtable.T4cache.get(key));
				return true;
			}

			Valuetype get(mkdb.Lockey[] locks, Long key) {
				this.locks = locks;
				this.key = key;
				if (false == this.call())
					throw new RuntimeException("readGet fail.", this.getException());
				return this.value;
			}
		}

		@Override
		protected Valuetype realGet(Long key) {
			return new RealGet().get(realGetLocks(key), key);
		}

		static CacheImpl instance = new CacheImpl();
	}

	////////////////////////////////////////////////////////////////////////////////
	// deepcopy helper
	public static java.util.Set<Integer> deepcopy(java.util.Set<Integer> _o_) {
		java.util.Set<Integer> _r_ = new java.util.HashSet<Integer>();
		_r_.addAll(_o_);
		return _r_;
	}

	public static xbean.Cacheb1 deepcopy(xbean.Cacheb1 _o_) {
		return _o_.toDataIf();
	}

	public static Valuetype.T4cache deepcopy(xbean.Cacheb0 b) {
		if (null == b) return null;

		Valuetype.T4cache r = new Valuetype.T4cache();
		r.i = b.getI();
		r.seti = deepcopy(b.getSeti());
		r.marshal = b.getMarshalCopy();
		r.cacheb1 = deepcopy(b.getCacheb1());
		return r;
	}

	/////////////////////////////////////////////////////////////////////////////////
	// Listener
	static void registryTableListener() {
		xtable.T4cache.getTable().addListener(_T4cache_cacheb1_Listener.instance, "value", "cacheb1");
		xtable.T4cache.getTable().addListener(_T4cache_i_Listener.instance, "value", "i");
		xtable.T4cache.getTable().addListener(_T4cache_marshal_Listener.instance, "value", "marshal");
		xtable.T4cache.getTable().addListener(_T4cache_seti_Listener.instance, "value", "seti");
	}

	static void unregistryTableListener() {
		xtable.T4cache.getTable().removeListener(_T4cache_cacheb1_Listener.instance, "value", "cacheb1");
		xtable.T4cache.getTable().removeListener(_T4cache_i_Listener.instance, "value", "i");
		xtable.T4cache.getTable().removeListener(_T4cache_marshal_Listener.instance, "value", "marshal");
		xtable.T4cache.getTable().removeListener(_T4cache_seti_Listener.instance, "value", "seti");
	}

	static class _T4cache_cacheb1_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.t4cache  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			cv.t4cache.cacheb1 = deepcopy(value.getCacheb1());
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.t4cache = null;
		}

		static _T4cache_cacheb1_Listener instance = new _T4cache_cacheb1_Listener();
	}

	static class _T4cache_i_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.t4cache  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			cv.t4cache.i = value.getI();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.t4cache = null;
		}

		static _T4cache_i_Listener instance = new _T4cache_i_Listener();
	}

	static class _T4cache_marshal_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.t4cache  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			cv.t4cache.marshal = value.getMarshalCopy();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.t4cache = null;
		}

		static _T4cache_marshal_Listener instance = new _T4cache_marshal_Listener();
	}

	static class _T4cache_seti_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.t4cache  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Cacheb0 value = xtable.T4cache.get(key);
			cv.t4cache.seti = deepcopy(value.getSeti());
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.t4cache = null;
		}

		static _T4cache_seti_Listener instance = new _T4cache_seti_Listener();
	}

}
