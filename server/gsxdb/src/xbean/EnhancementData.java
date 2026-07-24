
package xbean;

public interface EnhancementData extends mkdb.Bean {
	public EnhancementData copy(); // 深拷贝
	public EnhancementData toData(); // 一个 Data 实例
	public EnhancementData toBean(); // 一个 Bean 实例
	public EnhancementData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EnhancementData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getEnhancementattr(); // 附魔属性，作者 changhao
	public java.util.Map<Integer, Integer> getEnhancementattrAsData(); // 附魔属性，作者 changhao
	public long getEnhancementtime(); // 附魔时间，作者 changhao

	public void setEnhancementtime(long _v_); // 附魔时间，作者 changhao
}
