package fire.pb.ranklist.provider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fire.pb.map.Role;
import fire.pb.ranklist.SRequestRankList;
import fire.pb.ranklist.proc.RankListManager;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.OctetsStream;

/***
 * 等级排名
 * @作者昌浩
 *
 */
public class LevelRankData extends RankData implements IRankListData {

	LevelRankData(int rankype, long requestRoleid) {
		super(rankype, requestRoleid);
	}

	@Override
	public List<Octets> getMO(SRequestRankList response, int page) {
		xbean.RoleLevelRankList list = xtable.Rolelevellist.select(rankType);
		if(null == list){
			return null;
		}

		List<xbean.RoleLevelListRecord> levelList = list.getRecords();
		int start = page * RankListManager.PAGE_SIZE;
		int end = (page + 1)* RankListManager.PAGE_SIZE;
		int hasMorePage = (page + 1) * RankListManager.PAGE_SIZE < levelList.size() ? 0:1;

		List<com.locojoy.base.Octets> octets = new ArrayList<com.locojoy.base.Octets>();
		
		for(int i=0; i<levelList.size(); i++)
		{
			xbean.RoleLevelListRecord current = levelList.get(i);
			if(i >= start && i < end)
			{
				OctetsStream os = new OctetsStream();
				xbean.MarshalRoleLevelRecord marshalRecord = current.getMarshaldata();
				marshalRecord.setRank(i+1);
				xbean.Properties prop = xtable.Properties.select(marshalRecord.getRoleid());
				if (prop != null) {
					marshalRecord.setShape(prop.getShape());
					marshalRecord.setColor1(prop.getRolecolor1());
					marshalRecord.setColor2(prop.getRolecolor2());
				}
				HashMap<Byte, Integer> components = new HashMap<Byte, Integer>();
				Role.getPlayerComponents(marshalRecord.getRoleid(), components);
				os.marshal(marshalRecord.getRoleid());
				os.marshal(marshalRecord.getRolename(), "UTF-16LE");
				os.marshal(marshalRecord.getLevel());
				os.marshal(marshalRecord.getSchool());
				os.marshal(marshalRecord.getShape());
				os.marshal(marshalRecord.getRank());
				os.marshal(marshalRecord.getColor1());
				os.marshal(marshalRecord.getColor2());
				os.compact_uint32(components.size());
				for (Map.Entry<Byte, Integer> entry : components.entrySet()) {
					os.marshal(entry.getKey());
					os.marshal(entry.getValue());
				}
				octets.add(os);
			}
			if(current.getMarshaldata().getRoleid() == requestRoleid)
			{
				response.myrank = i+1;
			}
		}
		
		response.hasmore = hasMorePage;
		response.page = page;
		
		return octets;
	}
}
