
package xbean;

public interface TestLP extends mkdb.Bean {
	public TestLP copy(); // deep clone
	public TestLP toData(); // a Data instance
	public TestLP toBean(); // a Bean instance
	public TestLP toDataIf(); // a Data instance If need. else return this
	public TestLP toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // test Listener Performance
	public java.util.Set<Integer> getSet1(); // 
	public java.util.Set<Integer> getSet1AsData(); // 
	public java.util.Map<Integer, Integer> getMap1(); // 
	public java.util.Map<Integer, Integer> getMap1AsData(); // 
	public java.util.List<Integer> getList1(); // 
	public java.util.List<Integer> getList1AsData(); // 
	public java.util.Map<Integer, xbean.RB> getMap2(); // test update
	public java.util.Map<Integer, xbean.RB> getMap2AsData(); // test update
	public java.util.List<xbean.RB> getList2(); // test update
	public java.util.List<xbean.RB> getList2AsData(); // test update

	public void setI(int _v_); // test Listener Performance
}
