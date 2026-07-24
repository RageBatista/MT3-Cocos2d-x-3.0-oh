package fire.pb.event;

public interface EventHandler {
	/**
	 * 在事务中执行
	 * @参数e
	 */
	public void onEvent( Event e );
}
