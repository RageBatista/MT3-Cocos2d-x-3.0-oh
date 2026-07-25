/***********************************************************************
filename: 	Utils2.h
author:		eagle
purpose:	���ø�������
*************************************************************************/
#ifndef __UTILS2_H__
#define __UTILS2_H__

#include <string>

namespace MHSD_UTILS
{
	//�������ַ�����Դ��ȡ����ͻ�����Ϣ��ʾ����ͬ��
	const std::wstring GETSTRING(int id); //lua
	const std::wstring& GetEffectPath(int id); //lua
	const std::wstring& GetTipsMsg(int id);
}

#endif//__UTILS_H__
