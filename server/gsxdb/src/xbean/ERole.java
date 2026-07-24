
package xbean;

public interface ERole extends mkdb.Bean {
	public ERole copy(); // 深拷贝
	public ERole toData(); // 一个 Data 实例
	public ERole toBean(); // 一个 Bean 实例
	public ERole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ERole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Float> getFinalattrs(); // 最终属性 key = attr type
	public java.util.Map<Integer, Float> getFinalattrsAsData(); // 最终属性 key = attr type
	public java.util.Map<Integer, Float> getEffects(); // key = 效果类型id
	public java.util.Map<Integer, Float> getEffectsAsData(); // key = 效果类型id

}
