//  CEGUILoadingTaskManager.c
//  CEGUI

#include "CEGUILoadingTaskManager.h"
#include "CEGUIResLoadThread.h"
#include <assert.h>

namespace CEGUI {
	CCEGUITaskManager* CCEGUITaskManager::s_Instance = NULL;

	CCEGUITaskManager::CCEGUITaskManager()
		: m_pRunningTask(NULL)
	{
	}

	CCEGUITaskManager::~CCEGUITaskManager()
	{
		clearTaskQueue(m_vCacheTasks);
		clearTaskMap(m_mapFileTasks);
		clearTaskList(m_vParseTasks);
		clearTaskList(m_vFontTasks);
	}

	CCEGUITaskManager* CCEGUITaskManager::GetInstancePtr()
	{
		if (s_Instance == NULL)
		{
			s_Instance = new CCEGUITaskManager;
		}

		return s_Instance;
	}

	CCEGUITaskManager* CCEGUITaskManager::GetExistingInstancePtr()
	{
		return s_Instance;
	}

	// yeqing 2015-10-19
	void CCEGUITaskManager::destroy()
	{
		if (s_Instance != NULL)
		{
			delete s_Instance;
			s_Instance = NULL;
		}
	}

	bool CCEGUITaskManager::QueueTask(ITask* aPTask)
	{
		if (!aPTask)
		{
			return false;
		}

		core::CMutex::Scoped lock(m_mutexQueue);
		if (core::Thread::m_iFireCounter < core::Thread::m_iLimitFires + 10)
		{
			return queueTaskNoLock(aPTask);
		}

		m_vCacheTasks.push(aPTask);
		return true;
	}

	bool CCEGUITaskManager::queueTask(ITask* aPTask)
	{
		core::CMutex::Scoped lock(m_mutexQueue);
		return queueTaskNoLock(aPTask);
	}

	bool CCEGUITaskManager::queueTaskNoLock(ITask* aPTask)
	{
		if (aPTask->GetPri() == ITask::eTPFile) {
			m_mapFileTasks[aPTask->GetPriority()].push_back(aPTask);
		}
		else if (aPTask->GetPri() == ITask::eTPParse){
			m_vParseTasks.push_back(aPTask);
		}
		else if (aPTask->GetPri() == ITask::eTPFont){
			m_vFontTasks.push_back(aPTask);
		}
		else{
			return false;
		}
		CEGUIResLoadThread::WakeUp();
		core::Thread::m_iFireCounter++;
		return true;
	}

	ITask* CCEGUITaskManager::GetTask(ITask::enumThread eThread)
	{
		core::CMutex::Scoped lock(m_mutexQueue);
		return getTaskNoLock(eThread);
	}

	void CCEGUITaskManager::ExecuteNextTask()
	{
		ITask* pTask = NULL;
		{
			core::CMutex::Scoped lock(m_mutexQueue);
			pTask = getTaskNoLock(ITask::eWorkerThread);
			m_pRunningTask = pTask;
		}

		if (!pTask)
		{
			return;
		}

		try
		{
			pTask->Run();
		}
		catch (...)
		{
			try
			{
				pTask->HandleFailure();
			}
			catch (...)
			{
				pTask->Cancel();
			}
		}
		const bool deleteAfterRun = pTask->ShouldDeleteAfterRun();

		{
			core::CMutex::Scoped lock(m_mutexQueue);
			if (m_pRunningTask == pTask)
			{
				m_pRunningTask = NULL;
			}
		}

		if (deleteAfterRun)
		{
			delete pTask;
		}
	}

	void CCEGUITaskManager::CancelTasks(const void* owner)
	{
		if (!owner)
		{
			return;
		}

		core::CMutex::Scoped lock(m_mutexQueue);
		cancelTaskQueue(m_vCacheTasks, owner);
		cancelTaskMap(m_mapFileTasks, owner);
		cancelTaskList(m_vParseTasks, owner);
		cancelTaskList(m_vFontTasks, owner);

		if (m_pRunningTask && m_pRunningTask->References(owner))
		{
			m_pRunningTask->Cancel();
		}
	}

	bool CCEGUITaskManager::HasTaskFor(const void* owner)
	{
		if (!owner)
		{
			return false;
		}

		core::CMutex::Scoped lock(m_mutexQueue);
		if (m_pRunningTask && m_pRunningTask->References(owner))
		{
			return true;
		}

		return containsTask(m_vCacheTasks, owner) ||
			containsTask(m_mapFileTasks, owner) ||
			containsTask(m_vParseTasks, owner) ||
			containsTask(m_vFontTasks, owner);
	}

	bool CCEGUITaskManager::IsTaskRunning(const ITask* task)
	{
		core::CMutex::Scoped lock(m_mutexQueue);
		return task != NULL && m_pRunningTask == task;
	}

	bool    CCEGUITaskManager::LoadingFontEmpty()
	{
		core::CMutex::Scoped lock(m_mutexQueue);
		return m_vFontTasks.empty();
	}

	void CCEGUITaskManager::Update()
	{
		core::CMutex::Scoped lock(m_mutexQueue);
		while (!m_vCacheTasks.empty() &&
			core::Thread::m_iFireCounter < core::Thread::m_iLimitFires)
		{
			ITask* pTask = m_vCacheTasks.front();
			m_vCacheTasks.pop();
			if (!queueTaskNoLock(pTask))
			{
				delete pTask;
			}
		}
	}

	ITask* CCEGUITaskManager::getTaskNoLock(ITask::enumThread eThread)
	{
		ITask* pRet = NULL;
		if (!m_vFontTasks.empty() && eThread != ITask::eMainThread)
		{
			pRet = m_vFontTasks.front();
			m_vFontTasks.pop_front();
		}
		else if (!m_vParseTasks.empty())
		{
			pRet = m_vParseTasks.front();
			m_vParseTasks.pop_front();
		}
		else if (!m_mapFileTasks.empty())
		{
			std::map<float, std::list<ITask*> >::iterator ret = m_mapFileTasks.begin();
			pRet = ret->second.front();
			ret->second.pop_front();
			if (ret->second.empty())
			{
				m_mapFileTasks.erase(ret);
			}
		}
		return pRet;
	}

	void CCEGUITaskManager::clearTaskQueue(std::queue<ITask*>& tasks)
	{
		while (!tasks.empty())
		{
			delete tasks.front();
			tasks.pop();
		}
	}

	void CCEGUITaskManager::clearTaskList(std::list<ITask*>& tasks)
	{
		while (!tasks.empty())
		{
			delete tasks.front();
			tasks.pop_front();
		}
	}

	void CCEGUITaskManager::clearTaskMap(std::map<float, std::list<ITask*> >& tasks)
	{
		for (std::map<float, std::list<ITask*> >::iterator it = tasks.begin(); it != tasks.end(); ++it)
		{
			clearTaskList(it->second);
		}
		tasks.clear();
	}

	void CCEGUITaskManager::cancelTaskQueue(std::queue<ITask*>& tasks, const void* owner)
	{
		std::queue<ITask*> keep;
		while (!tasks.empty())
		{
			ITask* task = tasks.front();
			tasks.pop();
			if (task->References(owner))
			{
				task->Cancel();
				delete task;
			}
			else
			{
				keep.push(task);
			}
		}
		tasks = keep;
	}

	void CCEGUITaskManager::cancelTaskList(std::list<ITask*>& tasks, const void* owner)
	{
		for (std::list<ITask*>::iterator it = tasks.begin(); it != tasks.end();)
		{
			ITask* task = *it;
			if (task->References(owner))
			{
				task->Cancel();
				it = tasks.erase(it);
				delete task;
			}
			else
			{
				++it;
			}
		}
	}

	void CCEGUITaskManager::cancelTaskMap(std::map<float, std::list<ITask*> >& tasks, const void* owner)
	{
		for (std::map<float, std::list<ITask*> >::iterator it = tasks.begin(); it != tasks.end();)
		{
			cancelTaskList(it->second, owner);
			if (it->second.empty())
			{
				std::map<float, std::list<ITask*> >::iterator eraseIt = it++;
				tasks.erase(eraseIt);
			}
			else
			{
				++it;
			}
		}
	}

	bool CCEGUITaskManager::containsTask(std::queue<ITask*> tasks, const void* owner)
	{
		while (!tasks.empty())
		{
			if (tasks.front()->References(owner))
			{
				return true;
			}
			tasks.pop();
		}
		return false;
	}

	bool CCEGUITaskManager::containsTask(const std::list<ITask*>& tasks, const void* owner)
	{
		for (std::list<ITask*>::const_iterator it = tasks.begin(); it != tasks.end(); ++it)
		{
			if ((*it)->References(owner))
			{
				return true;
			}
		}
		return false;
	}

	bool CCEGUITaskManager::containsTask(const std::map<float, std::list<ITask*> >& tasks, const void* owner)
	{
		for (std::map<float, std::list<ITask*> >::const_iterator it = tasks.begin(); it != tasks.end(); ++it)
		{
			if (containsTask(it->second, owner))
			{
				return true;
			}
		}
		return false;
	}
}
