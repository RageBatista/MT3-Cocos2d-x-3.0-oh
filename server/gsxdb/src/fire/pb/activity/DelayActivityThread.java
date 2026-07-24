
package fire.pb.activity;

import fire.pb.util.MapUtil;

public class DelayActivityThread extends Thread {

	protected int mapid;

	protected long ownerid;

	protected long sceneid;

	public DelayActivityThread(int mapid, long ownerid) {
		this.mapid = mapid;
		this.ownerid = ownerid;
	}

	//传进来的副本是否就是这个activity需要执行的副本,子类可以覆盖这个方法
    public boolean sceneMatch(long sceneid,long ownerid){
    	int mapid=MapUtil.getBaseMapIdBySceneId(sceneid);
    	return this.mapid == mapid && this.ownerid == ownerid;
    }
    
	@Override
	public void run() {
		
	}
	
	public void setSceneid(long sceneid) {
	
		this.sceneid = sceneid;
	}

}
