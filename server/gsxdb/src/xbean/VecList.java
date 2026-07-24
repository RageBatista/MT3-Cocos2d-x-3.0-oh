
package xbean;

public interface VecList extends mkdb.Bean {
	public VecList copy(); // 深拷贝
	public VecList toData(); // 一个 Data 实例
	public VecList toBean(); // 一个 Bean 实例
	public VecList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public VecList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.MazeInfo> getList(); // 
	public java.util.List<xbean.MazeInfo> getListAsData(); // 

}
