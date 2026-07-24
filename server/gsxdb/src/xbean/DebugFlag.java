
package xbean;

public interface DebugFlag extends mkdb.Bean {
	public DebugFlag copy(); // 深拷贝
	public DebugFlag toData(); // 一个 Data 实例
	public DebugFlag toBean(); // 一个 Bean 实例
	public DebugFlag toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DebugFlag toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int BATTLE = 1; // 

	public java.util.List<Integer> getDebugs(); // 不在list中的为非调试状态
	public java.util.List<Integer> getDebugsAsData(); // 不在list中的为非调试状态

}
