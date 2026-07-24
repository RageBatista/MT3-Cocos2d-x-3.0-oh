
package xbean;

public interface GacdPicStatus extends mkdb.Bean {
	public GacdPicStatus copy(); // 深拷贝
	public GacdPicStatus toData(); // 一个 Data 实例
	public GacdPicStatus toBean(); // 一个 Bean 实例
	public GacdPicStatus toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GacdPicStatus toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getPictime(); // 答图形码的时间
	public String getAnswer(); // 正确答案
	public com.locojoy.base.Octets getAnswerOctets(); // 正确答案
	public int getResult(); // 答对还是答错
	public long getQuestiontime(); // 答题的时间,30分钟内不再出题

	public void setPictime(long _v_); // 答图形码的时间
	public void setAnswer(String _v_); // 正确答案
	public void setAnswerOctets(com.locojoy.base.Octets _v_); // 正确答案
	public void setResult(int _v_); // 答对还是答错
	public void setQuestiontime(long _v_); // 答题的时间,30分钟内不再出题
}
