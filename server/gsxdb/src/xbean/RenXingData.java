
package xbean;

public interface RenXingData extends mkdb.Bean {
	public RenXingData copy(); // 深拷贝
	public RenXingData toData(); // 一个 Data 实例
	public RenXingData toBean(); // 一个 Bean 实例
	public RenXingData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RenXingData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getRenxinmap(); // key 为循环类型
	public java.util.Map<Integer, Integer> getRenxinmapAsData(); // key 为循环类型

}
