package fire.pb.item;


public class SWenShiTaoZhuang implements mytools.ConvMain.Checkable ,Comparable<SWenShiTaoZhuang>{

	public int compareTo(SWenShiTaoZhuang o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SWenShiTaoZhuang(){
		super();
	}
	public SWenShiTaoZhuang(SWenShiTaoZhuang arg){
		this.id=arg.id ;
		this.zuhes=arg.zuhes ;
		this.jinengid=arg.jinengid ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * id
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> zuhes  ;
	
	public java.util.ArrayList<Integer> getZuhes(){
		return this.zuhes;
	}
	
	public void setZuhes(java.util.ArrayList<Integer> v){
		this.zuhes=v;
	}
	
	/**
	 * 
	 */
	public int jinengid  = 0  ;
	
	public int getJinengid(){
		return this.jinengid;
	}
	
	public void setJinengid(int v){
		this.jinengid=v;
	}
	
	
};