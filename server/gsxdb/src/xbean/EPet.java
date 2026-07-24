
package xbean;

public interface EPet extends mkdb.Bean {
	public EPet copy(); // 深拷贝
	public EPet toData(); // 一个 Data 实例
	public EPet toBean(); // 一个 Bean 实例
	public EPet toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EPet toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Float> getEffects(); // key = 效果类型id
	public java.util.Map<Integer, Float> getEffectsAsData(); // key = 效果类型id
	public java.util.Map<Integer, Float> getFinalattrs(); // key = 属性类型
	public java.util.Map<Integer, Float> getFinalattrsAsData(); // key = 属性类型

}
