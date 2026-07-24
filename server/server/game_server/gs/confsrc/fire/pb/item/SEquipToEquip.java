package fire.pb.item;


public class SEquipToEquip implements mytools.ConvMain.Checkable ,Comparable<SEquipToEquip>{

	public int compareTo(SEquipToEquip o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SEquipToEquip(){
		super();
	}
	public SEquipToEquip(SEquipToEquip arg){
		this.id=arg.id ;
		this.nextid1=arg.nextid1 ;
		this.nextid2=arg.nextid2 ;
		this.needid=arg.needid ;
		this.needid1num=arg.needid1num ;
		this.needid2num=arg.needid2num ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * 
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
	public int nextid1  = 0  ;
	
	public int getNextid1(){
		return this.nextid1;
	}
	
	public void setNextid1(int v){
		this.nextid1=v;
	}
	
	/**
	 * 
	 */
	public int nextid2  = 0  ;
	
	public int getNextid2(){
		return this.nextid2;
	}
	
	public void setNextid2(int v){
		this.nextid2=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> needid  ;
	
	public java.util.ArrayList<Integer> getNeedid(){
		return this.needid;
	}
	
	public void setNeedid(java.util.ArrayList<Integer> v){
		this.needid=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> needid1num  ;
	
	public java.util.ArrayList<Integer> getNeedid1num(){
		return this.needid1num;
	}
	
	public void setNeedid1num(java.util.ArrayList<Integer> v){
		this.needid1num=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> needid2num  ;
	
	public java.util.ArrayList<Integer> getNeedid2num(){
		return this.needid2num;
	}
	
	public void setNeedid2num(java.util.ArrayList<Integer> v){
		this.needid2num=v;
	}
	
	
};