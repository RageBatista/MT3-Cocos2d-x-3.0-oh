package fire.pb.ranklist.provider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fire.pb.PropRole;
import fire.pb.map.Role;
import fire.pb.ranklist.SRequestRankList;
import fire.pb.ranklist.proc.RankListManager;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.OctetsStream;

/***
 * 角色等级排行
 * @作者昌浩
 *
 */
public class RoleRankData extends RankData implements IRankListData{

	RoleRankData(int rankype, long requestRoleid) {
		super(rankype, requestRoleid);
	}

	@Override
	public List<Octets> getMO(SRequestRankList response, int page) {
		
		xbean.RoleRankList ranlListBean = xtable.Rolerankdatalist.select(1);
		
		PropRole prole = new PropRole(requestRoleid, true);		
		if(null == ranlListBean)
		{
			response.extdata = prole.getProperties().getRolescore();	
			return null;
		}

		List<xbean.RoleRankRecord> roleRankList = ranlListBean.getRecords();
		int start = page * RankListManager.PAGE_SIZE;
		int end = (page + 1)* RankListManager.PAGE_SIZE;
		int hasMorePage = (page + 1) * RankListManager.PAGE_SIZE < roleRankList.size() ? 0:1;
		List<com.locojoy.base.Octets> octets = new ArrayList<com.locojoy.base.Octets>();
		
		for(int i=0; i<roleRankList.size(); i++){
			xbean.RoleRankRecord current = roleRankList.get(i);
			if(i >= start && i < end) {
				OctetsStream os = new OctetsStream();
				os.marshal(i+1);
				os.marshal(current.getRoleid());
				os.marshal(current.getRolename(), "UTF-16LE");
				os.marshal(current.getSchool());
				os.marshal(current.getScore());
				os.marshal(current.getLevel());
				xbean.Properties prop = xtable.Properties.select(current.getRoleid());
				if (prop != null) {
					os.marshal(prop.getShape());
					os.marshal(prop.getRolecolor1());
					os.marshal(prop.getRolecolor2());
					HashMap<Byte, Integer> components = new HashMap<Byte, Integer>();
					Role.getPlayerComponents(current.getRoleid(), components);
					os.compact_uint32(components.size());
					for (Map.Entry<Byte, Integer> entry : components.entrySet()) {
						os.marshal(entry.getKey());
						os.marshal(entry.getValue());
					}
				} else {
					os.marshal(current.getShape());
					os.marshal(current.getColor1());
					os.marshal(current.getColor2());
					os.compact_uint32(current.getComponents().size());
					for (Map.Entry<Integer, Integer> entry : current.getComponents().entrySet()) {
						os.marshal(entry.getKey().byteValue());
						os.marshal(entry.getValue());
					}
				}
				octets.add(os);
			}
			if(current.getRoleid() == requestRoleid){
				response.myrank = i+1;
			}
		}
		
		response.mytitle = String.valueOf(prole.getProperties().getRolescore());
		response.hasmore = hasMorePage;
		response.page = page;
	
		//计算自己的评分，作者 changhao
		response.extdata = prole.getProperties().getRolescore();
		
		return octets;
	}

}
