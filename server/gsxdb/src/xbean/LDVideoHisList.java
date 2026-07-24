
package xbean;

public interface LDVideoHisList extends mkdb.Bean {
	public LDVideoHisList copy(); // 深拷贝
	public LDVideoHisList toData(); // 一个 Data 实例
	public LDVideoHisList toBean(); // 一个 Bean 实例
	public LDVideoHisList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LDVideoHisList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<String> getLdvidehisinfo(); // 生死战历史排行记录
	public java.util.List<String> getLdvidehisinfoAsData(); // 生死战历史排行记录

}
