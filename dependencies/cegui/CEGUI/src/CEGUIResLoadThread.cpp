//  CEGUIResLoadThread.cpp
//  CEGUI

#include "CEGUIResLoadThread.h"
#include "CEGUILoadingTaskManager.h"

namespace CEGUI
{
    CEGUIResLoadThread* CEGUIResLoadThread::s_Thread = NULL;
    
    CEGUIResLoadThread::CEGUIResLoadThread()
		: Thread(), m_semaphore("CEGUIResLoadThread")
    {
        
    }
    
    CEGUIResLoadThread::~CEGUIResLoadThread()
    {
    }
    
    CEGUIResLoadThread* CEGUIResLoadThread::GetPtr()
    {
        if(s_Thread == NULL)
        {
            s_Thread = new CEGUIResLoadThread;
        }
        return s_Thread;
    }
    
    void CEGUIResLoadThread::Run()
    {
		while (true)
		{
			m_semaphore.wait();

			if (!IsRunningNow())
			{
				break;
			}

			CCEGUITaskManager::GetInstancePtr()->ExecuteNextTask();
		}

		CCEGUITaskManager::destroy();
    }

	void CEGUIResLoadThread::WakeUp()
	{
		if (s_Thread != NULL)
		{
			s_Thread->m_semaphore.fire();
		}
	}

	// yeqing 2015-10-19
	void CEGUIResLoadThread::Destroy()
	{
		if (s_Thread != NULL)
		{
			s_Thread->StopRunning();
			s_Thread->m_semaphore.fire();
			s_Thread->Join();
			delete s_Thread;
			s_Thread = NULL;
		}
	}

}
