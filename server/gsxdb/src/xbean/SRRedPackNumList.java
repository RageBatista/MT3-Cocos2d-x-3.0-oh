
package xbean;

public interface SRRedPackNumList extends mkdb.Bean {
	public SRRedPackNumList copy(); // 深拷贝
	public SRRedPackNumList toData(); // 一个 Data 实例
	public SRRedPackNumList toBean(); // 一个 Bean 实例
	public SRRedPackNumList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SRRedPackNumList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.SRRedPackNum> getSrredpacknumlist(); // 
	public java.util.Map<Integer, xbean.SRRedPackNum> getSrredpacknumlistAsData(); // 

}
