#include "stdafx.h"
#include <cctype>
#include <list>
#include <shellapi.h>
#include <sstream>
#include <string>
#include <vector>

#pragma comment(lib, "Comctl32.lib")
#pragma comment(lib, "Comdlg32.lib")
#pragma comment(lib, "Shell32.lib")
#pragma comment(lib, "Ole32.lib")

namespace
{
const wchar_t* kWindowClassName = L"SplitImagesetGuiWindow";
const wchar_t* kWindowTitle = L"SplitImageset GUI";

enum
{
    IDC_EDIT_CONFIG = 101,
    IDC_BTN_CONFIG = 102,
    IDC_EDIT_ROOT = 103,
    IDC_BTN_ROOT = 104,
    IDC_CHECK_BACKUP = 105,
    IDC_BTN_RUN = 106,
    IDC_BTN_CLEAR = 107,
    IDC_EDIT_LOG = 108,
    IDC_LBL_STATUS = 109
};

enum SplitType
{
    SPLIT_ONLY_WIDTH = 0,
    SPLIT_ONLY_HEIGHT = 1,
    SPLIT_WIDTH_AND_HEIGHT = 2
};

struct SplitFrame
{
    std::string imageset;
    std::string image;
    SplitType type;
    int leftWidth;
    int centerWidth;
    int rightWidth;
    int topHeight;
    int centerHeight;
    int bottomHeight;
    int index;
};

struct ImageInfo
{
    std::string name;
    int x;
    int y;
    int width;
    int height;
};

struct RunSummary
{
    int total;
    int success;
    int failed;
    RunSummary() : total(0), success(0), failed(0) {}
};

HWND g_hEditConfig = NULL;
HWND g_hEditRoot = NULL;
HWND g_hCheckBackup = NULL;
HWND g_hEditLog = NULL;
HWND g_hStatus = NULL;
bool g_batchMode = false;
std::wstring g_batchLogPath;

std::wstring Trim(const std::wstring& text)
{
    size_t begin = 0;
    size_t end = text.size();
    while (begin < end && iswspace(text[begin]))
    {
        ++begin;
    }
    while (end > begin && iswspace(text[end - 1]))
    {
        --end;
    }
    return text.substr(begin, end - begin);
}

std::wstring Utf8OrAcpToWide(const std::string& text)
{
    if (text.empty())
    {
        return L"";
    }

    int wideChars = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, text.c_str(), (int)text.size(), NULL, 0);
    UINT cp = CP_UTF8;
    DWORD flags = MB_ERR_INVALID_CHARS;
    if (wideChars <= 0)
    {
        cp = CP_ACP;
        flags = 0;
        wideChars = MultiByteToWideChar(cp, flags, text.c_str(), (int)text.size(), NULL, 0);
    }
    if (wideChars <= 0)
    {
        return L"";
    }

    std::wstring result;
    result.resize(wideChars);
    MultiByteToWideChar(cp, flags, text.c_str(), (int)text.size(), &result[0], wideChars);
    return result;
}

std::wstring NumberToWide(int value)
{
    wchar_t buffer[32] = {0};
    _snwprintf_s(buffer, _countof(buffer), _TRUNCATE, L"%d", value);
    return buffer;
}

void AppendLog(bool isError, const std::wstring& line)
{
    std::wstring prefix = isError ? L"[ERROR] " : L"[INFO] ";
    std::wstring text = prefix + line + L"\r\n";

    if (g_batchMode && !g_batchLogPath.empty())
    {
        FILE* logFile = NULL;
        if (_wfopen_s(&logFile, g_batchLogPath.c_str(), L"a+, ccs=UTF-8") == 0 && logFile != NULL)
        {
            fwprintf(logFile, L"%ls", text.c_str());
            fclose(logFile);
        }
    }

    if (g_hEditLog == NULL)
    {
        OutputDebugStringW(text.c_str());
        FILE* fp = isError ? stderr : stdout;
        if (fp != NULL)
        {
            fwprintf(fp, L"%ls", text.c_str());
            fflush(fp);
        }
        return;
    }

    int length = GetWindowTextLengthW(g_hEditLog);
    SendMessageW(g_hEditLog, EM_SETSEL, (WPARAM)length, (LPARAM)length);
    SendMessageW(g_hEditLog, EM_REPLACESEL, FALSE, (LPARAM)text.c_str());
}

void SetStatusText(const std::wstring& text)
{
    if (g_hStatus != NULL)
    {
        SetWindowTextW(g_hStatus, text.c_str());
    }
}

bool FileExistsW(const std::wstring& path)
{
    DWORD attr = GetFileAttributesW(path.c_str());
    return attr != INVALID_FILE_ATTRIBUTES && ((attr & FILE_ATTRIBUTE_DIRECTORY) == 0);
}

bool DirExistsW(const std::wstring& path)
{
    DWORD attr = GetFileAttributesW(path.c_str());
    return attr != INVALID_FILE_ATTRIBUTES && ((attr & FILE_ATTRIBUTE_DIRECTORY) != 0);
}

std::wstring JoinPath(const std::wstring& root, const std::wstring& fileName)
{
    if (fileName.empty())
    {
        return root;
    }
    if (fileName.size() > 1 && fileName[1] == L':')
    {
        return fileName;
    }
    if (root.empty())
    {
        return fileName;
    }
    if (root[root.size() - 1] == L'\\' || root[root.size() - 1] == L'/')
    {
        return root + fileName;
    }
    return root + L"\\" + fileName;
}

bool ReadAllBytes(const std::wstring& path, std::string& outText)
{
    FILE* fp = NULL;
    if (_wfopen_s(&fp, path.c_str(), L"rb") != 0 || fp == NULL)
    {
        return false;
    }
    if (fseek(fp, 0, SEEK_END) != 0)
    {
        fclose(fp);
        return false;
    }
    long length = ftell(fp);
    if (length < 0)
    {
        fclose(fp);
        return false;
    }
    rewind(fp);
    outText.clear();
    if (length > 0)
    {
        outText.resize((size_t)length);
        size_t n = fread(&outText[0], 1, (size_t)length, fp);
        if (n != (size_t)length)
        {
            fclose(fp);
            return false;
        }
    }
    fclose(fp);
    if (outText.size() >= 3 &&
        (unsigned char)outText[0] == 0xEF &&
        (unsigned char)outText[1] == 0xBB &&
        (unsigned char)outText[2] == 0xBF)
    {
        outText.erase(0, 3);
    }
    return true;
}

bool WriteAllBytes(const std::wstring& path, const std::string& text)
{
    FILE* fp = NULL;
    if (_wfopen_s(&fp, path.c_str(), L"wb") != 0 || fp == NULL)
    {
        return false;
    }
    if (!text.empty())
    {
        size_t n = fwrite(text.data(), 1, text.size(), fp);
        if (n != text.size())
        {
            fclose(fp);
            return false;
        }
    }
    fclose(fp);
    return true;
}

bool ParseSplitType(const std::string& text, SplitType& type)
{
    if (text == "OnlyWidth")
    {
        type = SPLIT_ONLY_WIDTH;
        return true;
    }
    if (text == "OnlyHeight")
    {
        type = SPLIT_ONLY_HEIGHT;
        return true;
    }
    if (text == "WidthAndHeight")
    {
        type = SPLIT_WIDTH_AND_HEIGHT;
        return true;
    }
    return false;
}

bool TryGetAttrValue(const std::string& tag, const char* name, std::string& value)
{
    std::string key = std::string(name) + "=\"";
    size_t begin = tag.find(key);
    if (begin == std::string::npos)
    {
        return false;
    }
    begin += key.size();
    size_t end = tag.find('"', begin);
    if (end == std::string::npos || end <= begin)
    {
        return false;
    }
    value = tag.substr(begin, end - begin);
    return true;
}

int TryGetIntAttrValue(const std::string& tag, const char* name, int defaultValue)
{
    std::string value;
    if (!TryGetAttrValue(tag, name, value))
    {
        return defaultValue;
    }
    return atoi(value.c_str());
}

bool ParseConfig(const std::wstring& configPath, std::vector<SplitFrame>& frames)
{
    std::string text;
    if (!ReadAllBytes(configPath, text))
    {
        AppendLog(true, L"Failed to read config file: " + configPath);
        return false;
    }

    frames.clear();
    size_t cursor = 0;
    int index = 1;
    while (true)
    {
        size_t begin = text.find("<frame", cursor);
        if (begin == std::string::npos)
        {
            break;
        }
        size_t end = text.find('>', begin);
        if (end == std::string::npos)
        {
            AppendLog(true, L"Config parse failed: frame tag is not closed.");
            return false;
        }

        std::string tag = text.substr(begin, end - begin + 1);
        SplitFrame frame;
        std::string imageset;
        std::string image;
        std::string type;
        if (!TryGetAttrValue(tag, "imageset", imageset) ||
            !TryGetAttrValue(tag, "image", image) ||
            !TryGetAttrValue(tag, "type", type))
        {
            AppendLog(true, L"frame#" + NumberToWide(index) + L" parse failed, required attributes missing.");
            return false;
        }

        SplitType splitType = SPLIT_ONLY_WIDTH;
        if (!ParseSplitType(type, splitType))
        {
            AppendLog(true, L"frame#" + NumberToWide(index) + L" has invalid type value.");
            return false;
        }

        frame.imageset = imageset;
        frame.image = image;
        frame.type = splitType;
        frame.leftWidth = TryGetIntAttrValue(tag, "left_width", 0);
        frame.centerWidth = TryGetIntAttrValue(tag, "center_width", 0);
        frame.rightWidth = TryGetIntAttrValue(tag, "right_width", 0);
        frame.topHeight = TryGetIntAttrValue(tag, "top_height", 0);
        frame.centerHeight = TryGetIntAttrValue(tag, "center_height", 0);
        frame.bottomHeight = TryGetIntAttrValue(tag, "bottom_height", 0);
        frame.index = index;
        frames.push_back(frame);

        ++index;
        cursor = end + 1;
    }

    if (frames.empty())
    {
        AppendLog(true, L"No <frame> entries found in config.");
        return false;
    }
    return true;
}

bool ParseTagAttributes(const std::string& tag, std::vector<std::pair<std::string, std::string> >& attrs)
{
    attrs.clear();
    size_t pos = tag.find(' ');
    if (pos == std::string::npos)
    {
        return true;
    }

    while (pos < tag.size())
    {
        while (pos < tag.size() && isspace((unsigned char)tag[pos]))
        {
            ++pos;
        }
        if (pos >= tag.size() || tag[pos] == '/' || tag[pos] == '>')
        {
            break;
        }

        size_t keyBegin = pos;
        while (pos < tag.size() && tag[pos] != '=' && !isspace((unsigned char)tag[pos]) && tag[pos] != '>' && tag[pos] != '/')
        {
            ++pos;
        }
        if (pos <= keyBegin)
        {
            break;
        }
        std::string key = tag.substr(keyBegin, pos - keyBegin);

        while (pos < tag.size() && isspace((unsigned char)tag[pos]))
        {
            ++pos;
        }
        if (pos >= tag.size() || tag[pos] != '=')
        {
            break;
        }
        ++pos;
        while (pos < tag.size() && isspace((unsigned char)tag[pos]))
        {
            ++pos;
        }
        if (pos >= tag.size() || tag[pos] != '"')
        {
            break;
        }
        ++pos;
        size_t valueBegin = pos;
        size_t valueEnd = tag.find('"', valueBegin);
        if (valueEnd == std::string::npos)
        {
            break;
        }
        std::string value = tag.substr(valueBegin, valueEnd - valueBegin);
        attrs.push_back(std::make_pair(key, value));
        pos = valueEnd + 1;
    }

    return !attrs.empty();
}

bool TryFindAttr(const std::vector<std::pair<std::string, std::string> >& attrs, const char* name, std::string& value)
{
    for (size_t i = 0; i < attrs.size(); ++i)
    {
        if (attrs[i].first == name)
        {
            value = attrs[i].second;
            return true;
        }
    }
    return false;
}

bool LoadImageset(const std::wstring& imagesetPath, std::vector<std::pair<std::string, std::string> >& attrs, std::list<ImageInfo>& images)
{
    std::string text;
    if (!ReadAllBytes(imagesetPath, text))
    {
        AppendLog(true, L"Failed to read imageset file: " + imagesetPath);
        return false;
    }

    size_t headBegin = text.find("<Imageset");
    if (headBegin == std::string::npos)
    {
        AppendLog(true, L"Imageset root node missing: " + imagesetPath);
        return false;
    }
    size_t headEnd = text.find('>', headBegin);
    if (headEnd == std::string::npos)
    {
        AppendLog(true, L"Invalid Imageset header: " + imagesetPath);
        return false;
    }

    std::string headTag = text.substr(headBegin, headEnd - headBegin + 1);
    if (!ParseTagAttributes(headTag, attrs))
    {
        AppendLog(true, L"Failed to parse Imageset attributes: " + imagesetPath);
        return false;
    }

    images.clear();
    size_t cursor = headEnd + 1;
    while (true)
    {
        size_t imageBegin = text.find("<Image", cursor);
        if (imageBegin == std::string::npos)
        {
            break;
        }
        size_t imageEnd = text.find('>', imageBegin);
        if (imageEnd == std::string::npos)
        {
            AppendLog(true, L"Invalid Image tag in imageset: " + imagesetPath);
            return false;
        }

        std::string imageTag = text.substr(imageBegin, imageEnd - imageBegin + 1);
        std::vector<std::pair<std::string, std::string> > imageAttrs;
        if (!ParseTagAttributes(imageTag, imageAttrs))
        {
            AppendLog(true, L"Failed to parse Image attributes: " + imagesetPath);
            return false;
        }

        std::string name;
        std::string x;
        std::string y;
        std::string width;
        std::string height;
        if (!TryFindAttr(imageAttrs, "Name", name) ||
            !TryFindAttr(imageAttrs, "XPos", x) ||
            !TryFindAttr(imageAttrs, "YPos", y) ||
            !TryFindAttr(imageAttrs, "Width", width) ||
            !TryFindAttr(imageAttrs, "Height", height))
        {
            AppendLog(true, L"Image tag missing required attributes: " + imagesetPath);
            return false;
        }

        ImageInfo image;
        image.name = name;
        image.x = atoi(x.c_str());
        image.y = atoi(y.c_str());
        image.width = atoi(width.c_str());
        image.height = atoi(height.c_str());
        images.push_back(image);
        cursor = imageEnd + 1;
    }

    return true;
}

bool ValidateDimensions(const SplitFrame& frame, const ImageInfo& source)
{
    if (frame.type == SPLIT_ONLY_WIDTH)
    {
        if (frame.leftWidth <= 0 || frame.centerWidth <= 0 || frame.rightWidth <= 0)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" width segments must be > 0.");
            return false;
        }
        if (frame.leftWidth + frame.centerWidth + frame.rightWidth != source.width)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" width sum does not match source width.");
            return false;
        }
    }
    else if (frame.type == SPLIT_ONLY_HEIGHT)
    {
        if (frame.topHeight <= 0 || frame.centerHeight <= 0 || frame.bottomHeight <= 0)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" height segments must be > 0.");
            return false;
        }
        if (frame.topHeight + frame.centerHeight + frame.bottomHeight != source.height)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" height sum does not match source height.");
            return false;
        }
    }
    else
    {
        if (frame.leftWidth <= 0 || frame.centerWidth <= 0 || frame.rightWidth <= 0 ||
            frame.topHeight <= 0 || frame.centerHeight <= 0 || frame.bottomHeight <= 0)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" all nine-slice values must be > 0.");
            return false;
        }
        if (frame.leftWidth + frame.centerWidth + frame.rightWidth != source.width ||
            frame.topHeight + frame.centerHeight + frame.bottomHeight != source.height)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" nine-slice sum does not match source size.");
            return false;
        }
    }
    return true;
}

void GenerateSplitImages(const SplitFrame& frame, const ImageInfo& source, std::vector<ImageInfo>& output)
{
    output.clear();
    if (frame.type == SPLIT_ONLY_WIDTH)
    {
        ImageInfo left = source;
        left.name = source.name + "_l";
        left.width = frame.leftWidth;
        output.push_back(left);

        ImageInfo center = source;
        center.name = source.name + "_c";
        center.x += frame.leftWidth;
        center.width = frame.centerWidth;
        output.push_back(center);

        ImageInfo right = source;
        right.name = source.name + "_r";
        right.x += frame.leftWidth + frame.centerWidth;
        right.width = frame.rightWidth;
        output.push_back(right);
    }
    else if (frame.type == SPLIT_ONLY_HEIGHT)
    {
        ImageInfo top = source;
        top.name = source.name + "_t";
        top.height = frame.topHeight;
        output.push_back(top);

        ImageInfo center = source;
        center.name = source.name + "_c";
        center.y += frame.topHeight;
        center.height = frame.centerHeight;
        output.push_back(center);

        ImageInfo bottom = source;
        bottom.name = source.name + "_b";
        bottom.y += frame.topHeight + frame.centerHeight;
        bottom.height = frame.bottomHeight;
        output.push_back(bottom);
    }
    else
    {
        const char* names[3][3] = {
            {"_lt", "_lc", "_lb"},
            {"_ct", "_cc", "_cb"},
            {"_rt", "_rc", "_rb"}};
        int widths[3] = {frame.leftWidth, frame.centerWidth, frame.rightWidth};
        int heights[3] = {frame.topHeight, frame.centerHeight, frame.bottomHeight};
        int xoff[3] = {0, frame.leftWidth, frame.leftWidth + frame.centerWidth};
        int yoff[3] = {0, frame.topHeight, frame.topHeight + frame.centerHeight};
        for (int x = 0; x < 3; ++x)
        {
            for (int y = 0; y < 3; ++y)
            {
                ImageInfo part = source;
                part.name = source.name + names[x][y];
                part.x += xoff[x];
                part.y += yoff[y];
                part.width = widths[x];
                part.height = heights[y];
                output.push_back(part);
            }
        }
    }
}

int ApplySplit(std::list<ImageInfo>& images, const SplitFrame& frame)
{
    int replaced = 0;
    for (std::list<ImageInfo>::iterator it = images.begin(); it != images.end();)
    {
        if (it->name == frame.image)
        {
            if (!ValidateDimensions(frame, *it))
            {
                return -1;
            }

            std::vector<ImageInfo> parts;
            GenerateSplitImages(frame, *it, parts);
            for (size_t i = 0; i < parts.size(); ++i)
            {
                images.insert(it, parts[i]);
            }
            it = images.erase(it);
            ++replaced;
        }
        else
        {
            ++it;
        }
    }
    return replaced;
}

std::string BuildImagesetText(const std::vector<std::pair<std::string, std::string> >& attrs, const std::list<ImageInfo>& images)
{
    std::ostringstream output;
    output << "<Imageset";
    for (size_t i = 0; i < attrs.size(); ++i)
    {
        output << " " << attrs[i].first << "=\"" << attrs[i].second << "\"";
    }
    output << ">\n";
    for (std::list<ImageInfo>::const_iterator it = images.begin(); it != images.end(); ++it)
    {
        output << "    <Image Name=\"" << it->name
               << "\" XPos=\"" << it->x
               << "\" YPos=\"" << it->y
               << "\" Width=\"" << it->width
               << "\" Height=\"" << it->height
               << "\" />\n";
    }
    output << "</Imageset>\n";
    return output.str();
}

bool ProcessFrame(const SplitFrame& frame, const std::wstring& rootPath, bool backup, RunSummary& summary)
{
    ++summary.total;

    std::wstring imagesetPath = JoinPath(rootPath, Utf8OrAcpToWide(frame.imageset));
    std::wstring imageName = Utf8OrAcpToWide(frame.image);
    AppendLog(false, L"Processing frame#" + NumberToWide(frame.index) + L": " + imageName + L" @ " + imagesetPath);

    std::vector<std::pair<std::string, std::string> > attrs;
    std::list<ImageInfo> images;
    if (!LoadImageset(imagesetPath, attrs, images))
    {
        ++summary.failed;
        return false;
    }

    int replaced = ApplySplit(images, frame);
    if (replaced <= 0)
    {
        if (replaced == 0)
        {
            AppendLog(true, L"frame#" + NumberToWide(frame.index) + L" target image not found: " + imageName);
        }
        ++summary.failed;
        return false;
    }

    if (backup)
    {
        std::wstring backupPath = imagesetPath + L".bak";
        if (FileExistsW(backupPath))
        {
            DeleteFileW(backupPath.c_str());
        }
        if (!CopyFileW(imagesetPath.c_str(), backupPath.c_str(), FALSE))
        {
            AppendLog(true, L"Failed to create backup: " + imagesetPath);
            ++summary.failed;
            return false;
        }
    }

    std::string out = BuildImagesetText(attrs, images);
    if (!WriteAllBytes(imagesetPath, out))
    {
        AppendLog(true, L"Failed to write imageset: " + imagesetPath);
        ++summary.failed;
        return false;
    }

    AppendLog(false, L"frame#" + NumberToWide(frame.index) + L" done, replaced count: " + NumberToWide(replaced));
    ++summary.success;
    return true;
}

bool RunSplitProcess(const std::wstring& configPath, const std::wstring& rootPath, bool backup)
{
    if (!FileExistsW(configPath))
    {
        AppendLog(true, L"Config file does not exist: " + configPath);
        return false;
    }
    if (!DirExistsW(rootPath))
    {
        AppendLog(true, L"Imageset root directory does not exist: " + rootPath);
        return false;
    }

    std::vector<SplitFrame> frames;
    if (!ParseConfig(configPath, frames))
    {
        return false;
    }
    AppendLog(false, L"Loaded frame count: " + NumberToWide((int)frames.size()));

    RunSummary summary;
    for (size_t i = 0; i < frames.size(); ++i)
    {
        ProcessFrame(frames[i], rootPath, backup, summary);
    }

    std::wstring text = L"Finished: total " + NumberToWide(summary.total) +
                        L", success " + NumberToWide(summary.success) +
                        L", failed " + NumberToWide(summary.failed);
    AppendLog(summary.failed > 0, text);
    SetStatusText(summary.failed == 0 ? L"Status: all success" : L"Status: failed items exist");
    return summary.failed == 0;
}

std::wstring GetEditText(HWND edit)
{
    int len = GetWindowTextLengthW(edit);
    std::vector<wchar_t> buffer(len + 1, L'\0');
    GetWindowTextW(edit, &buffer[0], len + 1);
    return &buffer[0];
}

std::wstring GuessDefaultConfigPath()
{
    wchar_t modulePath[MAX_PATH] = {0};
    GetModuleFileNameW(NULL, modulePath, _countof(modulePath));
    std::wstring exeDir = modulePath;
    size_t slash = exeDir.find_last_of(L"\\/");
    if (slash != std::wstring::npos)
    {
        exeDir = exeDir.substr(0, slash);
    }
    return JoinPath(exeDir, L"SplitConfig.xml");
}

std::wstring GuessDefaultRootPath()
{
    wchar_t cwd[MAX_PATH] = {0};
    GetCurrentDirectoryW(_countof(cwd), cwd);
    std::wstring candidate = JoinPath(cwd, L"..\\res\\ui\\imagesets");
    if (DirExistsW(candidate))
    {
        return candidate;
    }
    return cwd;
}

void BrowseConfig(HWND owner)
{
    wchar_t path[MAX_PATH] = {0};
    std::wstring current = GetEditText(g_hEditConfig);
    if (!current.empty())
    {
        wcsncpy_s(path, _countof(path), current.c_str(), _TRUNCATE);
    }
    OPENFILENAMEW ofn = {0};
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = owner;
    ofn.lpstrFilter = L"XML Files (*.xml)\0*.xml\0All Files (*.*)\0*.*\0";
    ofn.lpstrFile = path;
    ofn.nMaxFile = _countof(path);
    ofn.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;
    if (GetOpenFileNameW(&ofn))
    {
        SetWindowTextW(g_hEditConfig, path);
    }
}

void BrowseRoot(HWND owner)
{
    BROWSEINFOW bi = {0};
    bi.hwndOwner = owner;
    bi.lpszTitle = L"Select imageset root folder";
    bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE | BIF_USENEWUI;
    LPITEMIDLIST pidl = SHBrowseForFolderW(&bi);
    if (pidl != NULL)
    {
        wchar_t path[MAX_PATH] = {0};
        if (SHGetPathFromIDListW(pidl, path))
        {
            SetWindowTextW(g_hEditRoot, path);
        }
        CoTaskMemFree(pidl);
    }
}

void UpdateLayout(HWND hwnd)
{
    RECT rc = {0};
    GetClientRect(hwnd, &rc);

    const int margin = 12;
    const int labelW = 120;
    const int rowH = 24;
    const int btnW = 96;
    int xEdit = margin + labelW;
    int xBtn = rc.right - margin - btnW;
    int editW = xBtn - xEdit - 8;

    int y = margin;
    MoveWindow(g_hEditConfig, xEdit, y, editW, rowH, TRUE);
    MoveWindow(GetDlgItem(hwnd, IDC_BTN_CONFIG), xBtn, y, btnW, rowH, TRUE);
    y += rowH + 8;
    MoveWindow(g_hEditRoot, xEdit, y, editW, rowH, TRUE);
    MoveWindow(GetDlgItem(hwnd, IDC_BTN_ROOT), xBtn, y, btnW, rowH, TRUE);
    y += rowH + 8;
    MoveWindow(g_hCheckBackup, xEdit, y, 240, rowH, TRUE);
    MoveWindow(GetDlgItem(hwnd, IDC_BTN_RUN), xBtn - btnW - 8, y, btnW, rowH, TRUE);
    MoveWindow(GetDlgItem(hwnd, IDC_BTN_CLEAR), xBtn, y, btnW, rowH, TRUE);
    y += rowH + 8;
    MoveWindow(g_hEditLog, margin, y, rc.right - margin * 2, rc.bottom - y - margin - 24, TRUE);
    MoveWindow(g_hStatus, margin, rc.bottom - margin - 20, rc.right - margin * 2, 20, TRUE);
}

LRESULT CALLBACK MainWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg)
    {
    case WM_CREATE:
    {
        HFONT hFont = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
        CreateWindowExW(0, L"STATIC", L"SplitConfig.xml:", WS_CHILD | WS_VISIBLE, 12, 12, 100, 24, hwnd, NULL, NULL, NULL);
        g_hEditConfig = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", GuessDefaultConfigPath().c_str(),
                                         WS_CHILD | WS_VISIBLE | ES_AUTOHSCROLL, 0, 0, 0, 0, hwnd,
                                         (HMENU)IDC_EDIT_CONFIG, NULL, NULL);
        CreateWindowExW(0, L"BUTTON", L"Browse...", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, 0, 0, 0, 0, hwnd,
                        (HMENU)IDC_BTN_CONFIG, NULL, NULL);

        CreateWindowExW(0, L"STATIC", L"Imageset Root:", WS_CHILD | WS_VISIBLE, 12, 44, 100, 24, hwnd, NULL, NULL, NULL);
        g_hEditRoot = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", GuessDefaultRootPath().c_str(),
                                       WS_CHILD | WS_VISIBLE | ES_AUTOHSCROLL, 0, 0, 0, 0, hwnd,
                                       (HMENU)IDC_EDIT_ROOT, NULL, NULL);
        CreateWindowExW(0, L"BUTTON", L"Browse...", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, 0, 0, 0, 0, hwnd,
                        (HMENU)IDC_BTN_ROOT, NULL, NULL);

        g_hCheckBackup = CreateWindowExW(0, L"BUTTON", L"Create .bak before overwrite",
                                          WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX, 0, 0, 0, 0, hwnd,
                                          (HMENU)IDC_CHECK_BACKUP, NULL, NULL);
        SendMessageW(g_hCheckBackup, BM_SETCHECK, BST_CHECKED, 0);
        CreateWindowExW(0, L"BUTTON", L"Run", WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON, 0, 0, 0, 0, hwnd,
                        (HMENU)IDC_BTN_RUN, NULL, NULL);
        CreateWindowExW(0, L"BUTTON", L"Clear Log", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, 0, 0, 0, 0, hwnd,
                        (HMENU)IDC_BTN_CLEAR, NULL, NULL);

        g_hEditLog = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", L"",
                                      WS_CHILD | WS_VISIBLE | ES_MULTILINE | ES_READONLY | ES_AUTOVSCROLL | WS_VSCROLL,
                                      0, 0, 0, 0, hwnd, (HMENU)IDC_EDIT_LOG, NULL, NULL);
        g_hStatus = CreateWindowExW(0, L"STATIC", L"Status: idle", WS_CHILD | WS_VISIBLE, 0, 0, 0, 0, hwnd,
                                    (HMENU)IDC_LBL_STATUS, NULL, NULL);

        SendMessageW(g_hEditConfig, WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(g_hEditRoot, WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(g_hCheckBackup, WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(g_hEditLog, WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(g_hStatus, WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(GetDlgItem(hwnd, IDC_BTN_CONFIG), WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(GetDlgItem(hwnd, IDC_BTN_ROOT), WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(GetDlgItem(hwnd, IDC_BTN_RUN), WM_SETFONT, (WPARAM)hFont, TRUE);
        SendMessageW(GetDlgItem(hwnd, IDC_BTN_CLEAR), WM_SETFONT, (WPARAM)hFont, TRUE);

        UpdateLayout(hwnd);
        return 0;
    }
    case WM_SIZE:
        UpdateLayout(hwnd);
        return 0;
    case WM_COMMAND:
    {
        WORD id = LOWORD(wParam);
        if (id == IDC_BTN_CONFIG)
        {
            BrowseConfig(hwnd);
            return 0;
        }
        if (id == IDC_BTN_ROOT)
        {
            BrowseRoot(hwnd);
            return 0;
        }
        if (id == IDC_BTN_CLEAR)
        {
            SetWindowTextW(g_hEditLog, L"");
            return 0;
        }
        if (id == IDC_BTN_RUN)
        {
            std::wstring configPath = Trim(GetEditText(g_hEditConfig));
            std::wstring rootPath = Trim(GetEditText(g_hEditRoot));
            bool backup = (SendMessageW(g_hCheckBackup, BM_GETCHECK, 0, 0) == BST_CHECKED);
            SetStatusText(L"Status: running...");
            bool ok = RunSplitProcess(configPath, rootPath, backup);
            MessageBoxW(hwnd, ok ? L"Done. All frames succeeded." : L"Done. Some frames failed.", kWindowTitle, MB_OK | (ok ? MB_ICONINFORMATION : MB_ICONWARNING));
            return 0;
        }
        break;
    }
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    default:
        break;
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}

bool TryRunBatchMode(int& exitCode)
{
    exitCode = 0;
    int argc = 0;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv == NULL)
    {
        return false;
    }

    bool batch = false;
    bool backup = true;
    std::wstring configPath;
    std::wstring rootPath;
    bool invalid = false;

    for (int i = 1; i < argc; ++i)
    {
        std::wstring arg = argv[i];
        if (arg == L"--batch")
        {
            batch = true;
        }
        else if (arg == L"--no-backup")
        {
            backup = false;
        }
        else if (arg == L"--config" && i + 1 < argc)
        {
            configPath = argv[++i];
        }
        else if (arg == L"--imageset-root" && i + 1 < argc)
        {
            rootPath = argv[++i];
        }
        else if (arg == L"--help")
        {
            batch = true;
            invalid = true;
            MessageBoxW(NULL,
                        L"Batch usage:\nSplitImageset.exe --batch --config <path> --imageset-root <dir> [--no-backup]",
                        kWindowTitle, MB_OK | MB_ICONINFORMATION);
        }
        else
        {
            batch = true;
            invalid = true;
            MessageBoxW(NULL, (L"Unknown argument: " + arg).c_str(), kWindowTitle, MB_OK | MB_ICONWARNING);
        }
    }

    LocalFree(argv);

    if (!batch)
    {
        return false;
    }

    if (invalid)
    {
        exitCode = 2;
        return true;
    }

    if (AttachConsole(ATTACH_PARENT_PROCESS) || AllocConsole())
    {
        FILE* fp = NULL;
        freopen_s(&fp, "CONOUT$", "w", stdout);
        freopen_s(&fp, "CONOUT$", "w", stderr);
    }

    if (configPath.empty())
    {
        configPath = GuessDefaultConfigPath();
    }
    if (rootPath.empty())
    {
        rootPath = GuessDefaultRootPath();
    }

    g_batchMode = true;
    g_batchLogPath = JoinPath(rootPath, L"splitimageset_batch.log");
    DeleteFileW(g_batchLogPath.c_str());
    bool ok = RunSplitProcess(configPath, rootPath, backup);
    g_batchMode = false;
    exitCode = ok ? 0 : 2;
    return true;
}

} // namespace

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE, LPWSTR, int nCmdShow)
{
    int batchExitCode = 0;
    if (TryRunBatchMode(batchExitCode))
    {
        return batchExitCode;
    }

    INITCOMMONCONTROLSEX ic = {0};
    ic.dwSize = sizeof(ic);
    ic.dwICC = ICC_STANDARD_CLASSES | ICC_WIN95_CLASSES;
    InitCommonControlsEx(&ic);
    OleInitialize(NULL);

    WNDCLASSEXW wc = {0};
    wc.cbSize = sizeof(wc);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = MainWndProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.lpszClassName = kWindowClassName;
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
    if (!RegisterClassExW(&wc))
    {
        OleUninitialize();
        return 1;
    }

    HWND hwnd = CreateWindowExW(0, kWindowClassName, kWindowTitle,
                                WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT,
                                940, 680, NULL, NULL, hInstance, NULL);
    if (hwnd == NULL)
    {
        OleUninitialize();
        return 1;
    }

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    MSG msg = {0};
    while (GetMessageW(&msg, NULL, 0, 0) > 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    OleUninitialize();
    return (int)msg.wParam;
}
