/********************************************************************
    created:    2011/03/08
    filename:   CEGUIPfsResourceProvider.cpp
    purpose:    MT3 PFS resource provider - ported to CEGUI 0.7.9-r5
*********************************************************************/

#include "CEGUIPfsResourceProvider.h"
#include "CEGUIExceptions.h"
#include <algorithm>
#include <stdio.h>

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

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
    void PFSResourceProvider::loadRawDataContainer(const String& filename, LJFM::LJFMID& output, const String& resourceGroup)
    {
        // MT3: PFS loading - requires LJFM/Nuclear headers
        // For now, stub implementation
        throw InvalidRequestException(
            "PFSResourceProvider::loadRawDataContainer(LJFMID) - PFS loading not yet ported to CEGUI 0.7.9-r5");
    }
#else
    void PFSResourceProvider::loadRawDataContainer(const String& filename, RawDataContainer& output, const String& resourceGroup)
    {
        // MT3: PFS loading - requires LJFM/Nuclear headers
        // For now, stub implementation
        throw InvalidRequestException(
            "PFSResourceProvider::loadRawDataContainer - PFS loading not yet ported to CEGUI 0.7.9-r5");
    }
#endif

    void PFSResourceProvider::unloadRawDataContainer(RawDataContainer& data)
    {
        // No-op: data is managed externally
    }

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

    const String& PFSResourceProvider::getResourceGroupDirectory(const String& resourceGroup)
    {
        return d_resourceGroups[resourceGroup];
    }

    void PFSResourceProvider::clearResourceGroupDirectory(const String& resourceGroup)
    {
        ResourceGroupMap::iterator iter = d_resourceGroups.find(resourceGroup);

        if (iter != d_resourceGroups.end())
            d_resourceGroups.erase(iter);
    }

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