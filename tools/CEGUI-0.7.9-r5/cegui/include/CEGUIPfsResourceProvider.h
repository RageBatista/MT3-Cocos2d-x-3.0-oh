/********************************************************************
    created:    2011/03/07
    filename:   CEGUIPfsResourceProvider.h
    purpose:    MT3 PFS resource provider - minimal compatibility header for CEGUI 0.7.9-r5
*********************************************************************/

#ifndef _CEGUIPFSRESOURCEPROVIDER_H_
#define _CEGUIPFSRESOURCEPROVIDER_H_

#include "CEGUIBase.h"
#include "CEGUIResourceProvider.h"

// MT3: Forward declarations for LJFM types (used only in PUBLISHED_VERSION builds)
namespace LJFM { class LJFMF; class LJFMID; }

// Start of CEGUI namespace section
namespace CEGUI
{

class CEGUIEXPORT PFSResourceProvider : public ResourceProvider
{
public:
    PFSResourceProvider() {}
    ~PFSResourceProvider(void) {}

    void setResourceGroupDirectory(const String& resourceGroup, const String& directory);
    const String& getResourceGroupDirectory(const String& resourceGroup);
    void clearResourceGroupDirectory(const String& resourceGroup);

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
    void loadRawDataContainer(const String& filename, LJFM::LJFMID& output, const String& resourceGroup);
#else
    void loadRawDataContainer(const String& filename, RawDataContainer& output, const String& resourceGroup);
#endif
    void unloadRawDataContainer(RawDataContainer& data);
    size_t getResourceGroupFileNames(std::vector<String>& out_vec,
                                     const String& file_pattern,
                                     const String& resource_group);

public:
    std::wstring GetPFSFileName(const String& filename, const String& resourceGroup);

protected:
    String getFinalFilename(const String& filename, const String& resourceGroup) const;

    typedef std::map<String, String, String::FastLessCompare> ResourceGroupMap;
    ResourceGroupMap    d_resourceGroups;

public:
    // MT3: Static utility methods for FireClient backward compatibility
    static std::wstring GUIStringToWString(const String& cs)
    {
        std::wstring ret(cs.length(), 0);
        for (String::size_type i = 0; i != cs.length(); ++i)
        {
            ret[i] = static_cast<wchar_t>(cs[i]);
        }
        return ret;
    }

    static CEGUI::String WStringToGUIString(const std::wstring& wstr)
    {
        return CEGUI::String(wstr.c_str());
    }

    static bool IsValidateString(CEGUI::String string, size_t validateLen)
    {
        return GUIStringToWString(string).length() <= validateLen;
    }

    static bool IsValidateStringLength(CEGUI::String string, size_t maxlength, size_t minlength)
    {
        return GUIStringToWString(string).length() <= maxlength && GUIStringToWString(string).length() >= minlength;
    }
};

} // End of  CEGUI namespace section

#endif  // end of guard _CEGUIPFSResourceProvider_h_