package xcache;

public class _ConcurrentCaches_ extends mkdb.util.ConcurrentCaches {
	public _ConcurrentCaches_() {
	}

	@Override
	protected void onStart() {
		super.add(Mycache.getCache());
		super.add(Mycache2.getCache());
		super.add(Mycache3.getCache());

		Mycache.registryTableListener();
		Mycache2.registryTableListener();
		Mycache3.registryTableListener();
	}

	@Override
	protected void onStop() {
		Mycache.unregistryTableListener();
		Mycache2.unregistryTableListener();
		Mycache3.unregistryTableListener();
	}

}

