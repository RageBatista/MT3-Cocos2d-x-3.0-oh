<?php
namespace app\model;
use think\Model;

/**
 * 代理关系模型
 * 用于管理新的扁平化代理层级关系
 */
class AgentRelation extends Model
{
    protected $table = 'agent_relation';
    
    /**
     * 创建代理关系记录
     * @param int $agentId 代理ID
     * @param int|null $parentId 上级代理ID
     * @return bool
     */
    public function createRelation($agentId, $parentId = null)
    {
        $relation = new AgentRelation();
        $relation->agent_id = $agentId;
        $relation->parent_id = $parentId;
        
        if ($parentId) {
            // 获取上级关系
            $parentRelation = $this->getByAgentId($parentId);
            if ($parentRelation) {
                // 设置层级关系
                $relation->level_1_parent = $parentId;
                $relation->level_2_parent = $parentRelation['parent_id'];
                $relation->level = $parentRelation['level'] + 1;
                
                // 构建路径
                $parentPath = $parentRelation['path'] ? $parentRelation['path'] : $parentId;
                $relation->path = $parentPath . ',' . $agentId;
                
                // 更新上级的下级数量
                $this->incrementChildren($parentId);
            } else {
                // 上级不存在关系记录，创建一级代理
                $relation->level_1_parent = null;
                $relation->level_2_parent = null;
                $relation->level = 2;
                $relation->path = $parentId . ',' . $agentId;
            }
        } else {
            // 顶级代理
            $relation->level = 1;
            $relation->path = (string)$agentId;
        }
        
        return $relation->save();
    }
    
    /**
     * 根据代理ID获取关系记录
     * @param int $agentId
     * @return array|null
     */
    public function getByAgentId($agentId)
    {
        $relation = AgentRelation::where('agent_id', $agentId)->find();
        return $relation ? $relation->toArray() : null;
    }
    
    /**
     * 获取代理的所有直属下级
     * @param int $agentId
     * @return array
     */
    public function getDirectChildren($agentId)
    {
        $children = AgentRelation::where('parent_id', $agentId)->select();
        return $children ? $children->toArray() : [];
    }
    
    /**
     * 获取代理的一级下级（直属下级）
     * @param int $agentId
     * @return array
     */
    public function getLevel1Children($agentId)
    {
        return $this->getDirectChildren($agentId);
    }
    
    /**
     * 获取代理的二级下级（下级的下级）
     * @param int $agentId
     * @return array
     */
    public function getLevel2Children($agentId)
    {
        $level1Children = $this->getDirectChildren($agentId);
        $level2Children = [];
        
        foreach ($level1Children as $child) {
            $grandChildren = $this->getDirectChildren($child['agent_id']);
            $level2Children = array_merge($level2Children, $grandChildren);
        }
        
        return $level2Children;
    }
    
    /**
     * 检查代理是否可以创建下级
     * @param int $agentId
     * @return bool
     */
    public function canCreateAgent($agentId)
    {
        $relation = $this->getByAgentId($agentId);
        return $relation ? (bool)$relation['can_create_agent'] : false;
    }
    
    /**
     * 更新代理的直属玩家流水
     * @param int $agentId
     * @param float $amount
     * @return bool
     */
    public function updatePlayerAmount($agentId, $amount)
    {
        $relation = AgentRelation::where('agent_id', $agentId)->find();
        if (!$relation) {
            return false;
        }
        
        $relation->direct_player_amount += $amount;
        
        // 检查是否达到开通下级的条件（5000元）
        if ($relation->direct_player_amount >= 5000 && !$relation->can_create_agent) {
            $relation->can_create_agent = 1;
        }
        
        return $relation->save();
    }
    
    /**
     * 设置代理可以创建下级
     * @param int $agentId
     * @param bool $canCreate
     * @return bool
     */
    public function setCanCreateAgent($agentId, $canCreate = true)
    {
        $relation = AgentRelation::where('agent_id', $agentId)->find();
        if (!$relation) {
            return false;
        }
        
        $relation->can_create_agent = $canCreate ? 1 : 0;
        return $relation->save();
    }
    
    /**
     * 增加直属下级数量
     * @param int $agentId
     * @return bool
     */
    private function incrementChildren($agentId)
    {
        $relation = AgentRelation::where('agent_id', $agentId)->find();
        if (!$relation) {
            return false;
        }
        
        $relation->direct_children += 1;
        $relation->total_children += 1;
        
        // 递归更新所有上级的总下级数
        if ($relation->parent_id) {
            $this->incrementTotalChildren($relation->parent_id);
        }
        
        return $relation->save();
    }
    
    /**
     * 递归增加总下级数量
     * @param int $agentId
     */
    private function incrementTotalChildren($agentId)
    {
        $relation = AgentRelation::where('agent_id', $agentId)->find();
        if ($relation) {
            $relation->total_children += 1;
            $relation->save();
            
            if ($relation->parent_id) {
                $this->incrementTotalChildren($relation->parent_id);
            }
        }
    }
    
    /**
     * 获取代理层级关系统计
     * @param int $agentId
     * @return array
     */
    public function getAgentStats($agentId)
    {
        $relation = $this->getByAgentId($agentId);
        if (!$relation) {
            return [
                'level_1_count' => 0,
                'level_2_count' => 0,
                'total_children' => 0,
                'direct_children' => 0,
                'can_create_agent' => false,
                'direct_player_amount' => 0
            ];
        }
        
        $level1Children = $this->getLevel1Children($agentId);
        $level2Children = $this->getLevel2Children($agentId);
        
        return [
            'level_1_count' => count($level1Children),
            'level_2_count' => count($level2Children),
            'total_children' => $relation['total_children'],
            'direct_children' => $relation['direct_children'],
            'can_create_agent' => (bool)$relation['can_create_agent'],
            'direct_player_amount' => $relation['direct_player_amount'],
            'level_1_children' => array_column($level1Children, 'agent_id'),
            'level_2_children' => array_column($level2Children, 'agent_id')
        ];
    }
}

