/********************************************************************
    created:    2011/03/08
    filename:   CEGUIPfsResourceProvider.cpp
    purpose:    MT3 PFS resource provider - ported to CEGUI 0.7.9-r5
*********************************************************************/

#include "CEGUIPfsResourceProvider.h"
#include "CEGUIExceptions.h"
#include "CEGUILogger.h"
#include "CEGUIPropertyHelper.h"
#include <algorithm>
#include <stdio.h>

// LJFM PFS file system headers
#include "ljfm.h"

#if defined(ANDROID)
#include <android/log.h>
#define CEGUI_PROBE_LOG(...) __android_log_print(ANDROID_LOG_ERROR, "CEGUIProbe", __VA_ARGS__)
#else
#define CEGUI_PROBE_LOG(...) ((void)0)
#endif

static std::string CEGUIProbeHeadBytes(const void* data, size_t size)
{
    if (!data)
    {
        return "(null)";
    }
    if (size == 0)
    {
        return "(empty)";
    }
    const unsigned char* bytes = static_cast<const unsigned char*>(data);
    const size_t count = size < 16 ? size : 16;
    std::string out;
    char part[4];
    for (size_t i = 0; i < count; ++i)
    {
        if (i != 0)
        {
            out += " ";
        }
        sprintf(part, "%02X", bytes[i]);
        out += part;
    }
    return out;
}

#if defined(__WIN32__) || defined(_WIN32)
#   include <io.h>
#else
#   include <sys/types.h>
#   include <sys/stat.h>
#   include <dirent.h>
#   include <fnmatch.h>
#endif

// Start of CEGUI namespace section
namespace CEGUI
{

//----------------------------------------------------------------------------//
// MT3: RawDataContainer overload - always available (base class pure virtual)
// Uses LJFM to open PFS files
//----------------------------------------------------------------------------//
void PFSResourceProvider::loadRawDataContainer(const String& filename, RawDataContainer& output, const String& resourceGroup)
{
    std::string file(filename.c_str());

    // Log: method entry
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] Loading resource - file: " + filename +
        ", group: " + (resourceGroup.empty() ? "(default)" : resourceGroup),
        CEGUI::Informative);

    if (filename.empty())
    {
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] Error - empty filename",
            CEGUI::Errors);
        throw InvalidRequestException(
            "PFSResourceProvider::load - Filename supplied for data loading must be valid");
    }

    String final_filename(getFinalFilename(filename, resourceGroup));
    std::wstring pfsname = GUIStringToWString(final_filename);
    std::transform(pfsname.begin(), pfsname.end(), pfsname.begin(), ::tolower);

    // Log: full path
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] Full path: " + final_filename,
        CEGUI::Informative);

    LJFM::LJFMF Afile;
    if (!Afile.Open(pfsname, LJFM::FM_EXCL, LJFM::FA_RDONLY))
    {
        // Log: file open failed
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] File open failed - path: " + final_filename,
            CEGUI::Errors);
        return;
    }

    // Log: file opened successfully
    int file_size = (int)Afile.GetSize();
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] File opened - size: " +
        PropertyHelper::intToString(file_size) + " bytes",
        CEGUI::Informative);

    if (file_size == 0)
    {
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] File size is 0 - path: " + final_filename,
            CEGUI::Errors);
        return;
    }

    CEGUI::uint8* data = new CEGUI::uint8[Afile.GetImage().GetSize()];
    memcpy(data, Afile.GetImage().GetData(), Afile.GetSize());
    output.setData(data);
    output.setSize(Afile.GetImage().GetSize());

    // Log: file read successfully
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] File read successfully - bytes: " +
        PropertyHelper::uintToString((uint)output.getSize()),
        CEGUI::Informative);
}

//----------------------------------------------------------------------------//
// MT3: LJFM::LJFMID overload - only available in PUBLISHED_VERSION builds
//----------------------------------------------------------------------------//
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
void PFSResourceProvider::loadRawDataContainer(const String& filename, LJFM::LJFMID& output, const String& resourceGroup)
{
    std::string file(filename.c_str());

    // Log: method entry
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] Loading resource (LJFMID) - file: " + filename +
        ", group: " + (resourceGroup.empty() ? "(default)" : resourceGroup),
        CEGUI::Informative);

    if (filename.empty())
    {
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] Error - empty filename",
            CEGUI::Errors);
        throw InvalidRequestException(
            "PFSResourceProvider::load - Filename supplied for data loading must be valid");
    }

    String final_filename(getFinalFilename(filename, resourceGroup));
    std::wstring pfsname = GUIStringToWString(final_filename);
    std::transform(pfsname.begin(), pfsname.end(), pfsname.begin(), ::tolower);

    // Log: full path
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] Full path: " + final_filename,
        CEGUI::Informative);

    LJFM::LJFMF Afile;
    if (!Afile.Open(pfsname, LJFM::FM_EXCL, LJFM::FA_RDONLY))
    {
        // Log: file open failed
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] File open failed - path: " + final_filename,
            CEGUI::Errors);
        return;
    }

    // Log: file opened successfully
    int file_size = (int)Afile.GetSize();
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] File opened - size: " +
        PropertyHelper::intToString(file_size) + " bytes",
        CEGUI::Informative);

    if (file_size == 0)
    {
        CEGUI::Logger::getSingleton().logEvent(
            "[PFSResourceProvider::loadRawDataContainer] File size is 0 - path: " + final_filename,
            CEGUI::Errors);
        return;
    }

    output = Afile.GetImage();
    CEGUI_PROBE_LOG("PFS load filename=%s group=%s final=%s afileSize=%d imageSize=%llu head=%s",
        filename.c_str(),
        resourceGroup.empty() ? "" : resourceGroup.c_str(),
        final_filename.c_str(),
        file_size,
        (unsigned long long)output.GetSize(),
        CEGUIProbeHeadBytes(output.GetData(), (size_t)output.GetSize()).c_str());

    // Log: file read successfully
    CEGUI::Logger::getSingleton().logEvent(
        "[PFSResourceProvider::loadRawDataContainer] File read successfully - bytes: " +
        PropertyHelper::intToString(file_size),
        CEGUI::Informative);
}
#endif

//----------------------------------------------------------------------------//
void PFSResourceProvider::unloadRawDataContainer(RawDataContainer& data)
{
    // Data is managed externally; no-op for now
    // uint8* ptr = data.getDataPtr();
    // delete ptr;
    // data.setData(0);
    // data.setSize(0);
}

//----------------------------------------------------------------------------//
void PFSResourceProvider::setResourceGroupDirectory(const String& resourceGroup, const String& directory)
{
    if (directory.length() == 0)
        return;

#if defined(_WIN32) || defined(__WIN32__)
    const String separators("\\/");
#else
    const String separators("/");
#endif

    if (String::npos == separators.find(directory[directory.length() - 1]))
        d_resourceGroups[resourceGroup] = directory + '/';
    else
        d_resourceGroups[resourceGroup] = directory;
}

//----------------------------------------------------------------------------//
const String& PFSResourceProvider::getResourceGroupDirectory(const String& resourceGroup)
{
    return d_resourceGroups[resourceGroup];
}

//----------------------------------------------------------------------------//
void PFSResourceProvider::clearResourceGroupDirectory(const String& resourceGroup)
{
    ResourceGroupMap::iterator iter = d_resourceGroups.find(resourceGroup);

    if (iter != d_resourceGroups.end())
        d_resourceGroups.erase(iter);
}

//----------------------------------------------------------------------------//
String PFSResourceProvider::getFinalFilename(const String& filename, const String& resourceGroup) const
{
    String final_filename;

    ResourceGroupMap::const_iterator iter =
        d_resourceGroups.find(resourceGroup.empty() ? d_defaultResourceGroup : resourceGroup);

    if (iter != d_resourceGroups.end())
        final_filename = (*iter).second;

    final_filename += filename;

    return final_filename;
}

//----------------------------------------------------------------------------//
std::wstring PFSResourceProvider::GetPFSFileName(const String& filename, const String& resourceGroup)
{
    String final_filename;

    ResourceGroupMap::const_iterator iter =
        d_resourceGroups.find(resourceGroup.empty() ? d_defaultResourceGroup : resourceGroup);

    if (iter != d_resourceGroups.end())
        final_filename = (*iter).second;

    final_filename += filename;

    std::wstring wstrfilename = GUIStringToWString(final_filename);
    std::transform(wstrfilename.begin(), wstrfilename.end(), wstrfilename.begin(), ::tolower);

    return wstrfilename;
}

//----------------------------------------------------------------------------//
size_t PFSResourceProvider::getResourceGroupFileNames(
    std::vector<String>& out_vec,
    const String& file_pattern,
    const String& resource_group)
{
    ResourceGroupMap::const_iterator iter =
        d_resourceGroups.find(resource_group.empty() ? d_defaultResourceGroup :
                                                       resource_group);
    const String dir_name(iter != d_resourceGroups.end() ? (*iter).second : "./");

    size_t entries = 0;

#if defined(__WIN32__) || defined(_WIN32)
    intptr_t f;
    struct _finddata_t fd;
    if ((f = _findfirst((dir_name + file_pattern).c_str(), &fd)) != -1)
    {
        do
        {
            if ((fd.attrib & _A_SUBDIR))
                continue;

            out_vec.push_back(fd.name);
            ++entries;
        } while (_findnext(f, &fd) == 0);

        _findclose(f);
    }
#else
    DIR* dirp;
    if ((dirp = opendir(dir_name.c_str())))
    {
        struct dirent* dp;
        while ((dp = readdir(dirp)))
        {
            const String filename(dir_name + dp->d_name);
            struct stat s;

            if ((stat(filename.c_str(), &s) == 0) &&
                S_ISREG(s.st_mode) &&
                (fnmatch(file_pattern.c_str(), dp->d_name, 0) == 0))
            {
                out_vec.push_back(dp->d_name);
                ++entries;
            }
        }

        closedir(dirp);
    }
#endif
    return entries;
}

} // End of  CEGUI namespace section