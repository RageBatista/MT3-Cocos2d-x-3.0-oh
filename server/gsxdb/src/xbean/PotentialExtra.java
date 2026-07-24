
package xbean;

public interface PotentialExtra extends mkdb.Bean {
	public PotentialExtra copy(); // 深拷贝
	public PotentialExtra toData(); // 一个 Data 实例
	public PotentialExtra toBean(); // 一个 Bean 实例
	public PotentialExtra toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PotentialExtra toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getExtramap(); // 潜灵果额外属性 key=属性类型 value=属性值
	public java.util.Map<Integer, Integer> getExtramapAsData(); // 潜灵果额外属性 key=属性类型 value=属性值

}
