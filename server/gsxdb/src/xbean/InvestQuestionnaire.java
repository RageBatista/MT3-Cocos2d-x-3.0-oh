
package xbean;

public interface InvestQuestionnaire extends mkdb.Bean {
	public InvestQuestionnaire copy(); // 深拷贝
	public InvestQuestionnaire toData(); // 一个 Data 实例
	public InvestQuestionnaire toBean(); // 一个 Bean 实例
	public InvestQuestionnaire toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InvestQuestionnaire toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getAnswer(); // key为题目,value为答案
	public java.util.Map<Integer, Integer> getAnswerAsData(); // key为题目,value为答案

}
