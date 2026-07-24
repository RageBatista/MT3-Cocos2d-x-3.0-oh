//////////////////////////////////////////////////////////////////////////
// File:		main.cpp
// Author:	Feng
// Date:		2016/03/04
// Modified: 2026-01-13 - Add atomic write, multi-threading, error handling
//////////////////////////////////////////////////////////////////////////

#include <io.h>
#include <string>
#include <vector>
#include <atomic>
#include <thread>
#include <mutex>
#include "BinLayout/CEGUIXMLToBin.h"
#include "CEGUIString.h"
#include "CEGUIDefaultLogger.h"
#include "BinLayout/v1/CEGUIRegSerializers_v1.h"
#include <Windows.h>

//////////////////////////////////////////////////////////////////////////
// Command line options
//////////////////////////////////////////////////////////////////////////
struct Options
{
	bool createBackup;   // --backup: create .bak backup files
	bool parallelMode;   // --parallel: enable multi-threaded mode
	int threadCount;     // --threads=N: thread count (default 4)
	bool legacyMode;     // --legacy: use legacy (unsafe) conversion

	Options()
		: createBackup(false)
		, parallelMode(false)
		, threadCount(4)
		, legacyMode(false)
	{}
};

//////////////////////////////////////////////////////////////////////////
// Atomic write: prevent data loss on conversion failure
//////////////////////////////////////////////////////////////////////////
namespace SafeIO
{
	// Safe file copy
	static bool copyFile(const std::string& src, const std::string& dst)
	{
		return CopyFileA(src.c_str(), dst.c_str(), FALSE) != 0;
	}

	// Safe file delete
	static bool deleteFile(const std::string& path)
	{
		return DeleteFileA(path.c_str()) != 0 || GetLastError() == ERROR_FILE_NOT_FOUND;
	}

	// Safe file rename
	static bool moveFile(const std::string& src, const std::string& dst)
	{
		return MoveFileExA(src.c_str(), dst.c_str(), MOVEFILE_REPLACE_EXISTING) != 0;
	}

	// Atomic conversion: write to temp file first, then replace on success
	static bool safeConvert(
		CEGUI::BinLayout::XMLToBin& converter,
		const std::string& srcPath,
		bool createBackup,
		std::string& outError)
	{
		// 1. Generate temp file path
		std::string tempPath = srcPath + ".tmp";
		std::string backupPath = srcPath + ".bak";

		// 2. Convert to temp file
		if (!converter.convert(srcPath, tempPath))
		{
			deleteFile(tempPath);
			outError = "Conversion failed";
			return false;
		}

		// 3. Verify temp file exists
		DWORD attr = GetFileAttributesA(tempPath.c_str());
		if (attr == INVALID_FILE_ATTRIBUTES)
		{
			outError = "Temp file not created";
			return false;
		}

		// 4. Create backup (optional)
		if (createBackup)
		{
			copyFile(srcPath, backupPath);
		}

		// 5. Atomic replace: rename temp file to original
		if (!moveFile(tempPath, srcPath))
		{
			// Rollback: keep original file if replace fails
			DWORD err = GetLastError();
			char buf[256];
			sprintf_s(buf, "Replace failed (error %lu)", err);
			outError = buf;
			deleteFile(tempPath);
			return false;
		}

		return true;
	}
}

//////////////////////////////////////////////////////////////////////////
// Multi-threaded batch conversion
//////////////////////////////////////////////////////////////////////////
namespace ParallelConvert
{
	static std::mutex g_logMutex;
	static std::atomic<int> g_successCount(0);
	static std::atomic<int> g_failCount(0);
	static std::atomic<int> g_skipCount(0);

	struct ConvertTask
	{
		std::string path;
		bool createBackup;
	};

	static void workerThread(
		std::vector<ConvertTask>& tasks,
		std::atomic<size_t>& taskIndex,
		size_t totalCount)
	{
		// Each thread has its own converter instance (avoid shared state)
		CEGUI::BinLayout::XMLToBin converter;

		while (true)
		{
			size_t idx = taskIndex.fetch_add(1);
			if (idx >= tasks.size())
			{
				break;
			}

			const ConvertTask& task = tasks[idx];
			std::string error;
			bool success = SafeIO::safeConvert(converter, task.path, task.createBackup, error);

			// Thread-safe logging
			{
				std::lock_guard<std::mutex> lock(g_logMutex);
				if (success)
				{
					printf("[%zu/%zu] OK: %s\n", idx + 1, totalCount, task.path.c_str());
					++g_successCount;
				}
				else
				{
					printf("[%zu/%zu] FAILED: %s (%s)\n", idx + 1, totalCount, task.path.c_str(), error.c_str());
					++g_failCount;
				}
			}
		}
	}

	static void runParallel(std::vector<ConvertTask>& tasks, int threadCount)
	{
		if (tasks.empty())
		{
			return;
		}

		g_successCount = 0;
		g_failCount = 0;
		g_skipCount = 0;

		std::atomic<size_t> taskIndex(0);
		size_t totalCount = tasks.size();

		// Limit thread count
		if (threadCount <= 0)
		{
			threadCount = 1;
		}
		if (threadCount > 8)
		{
			threadCount = 8;
		}
		if (static_cast<size_t>(threadCount) > tasks.size())
		{
			threadCount = static_cast<int>(tasks.size());
		}

		printf("Starting conversion with %d threads...\n", threadCount);

		std::vector<std::thread> threads;
		for (int i = 0; i < threadCount; ++i)
		{
			threads.emplace_back(workerThread, std::ref(tasks), std::ref(taskIndex), totalCount);
		}

		for (auto& t : threads)
		{
			t.join();
		}

		printf("\nConversion complete: %d success, %d failed, %d skipped\n",
			g_successCount.load(), g_failCount.load(), g_skipCount.load());
	}
}

void showHelp()
{
	printf("BinLayoutConvert - CEGUI layout XML to BIN converter\n");
	printf("\n");
	printf("Usage:\n");
	printf("  BinLayoutConvert [options] <filename|directory>\n");
	printf("\n");
	printf("Options:\n");
	printf("  --backup      Create .bak backup files before conversion\n");
	printf("  --parallel    Enable multi-threaded batch conversion\n");
	printf("  --threads=N   Set thread count for parallel mode (default: 4, max: 8)\n");
	printf("  --legacy      Use legacy (unsafe) in-place conversion\n");
	printf("  --help        Show this help message\n");
	printf("\n");
	printf("Examples:\n");
	printf("  BinLayoutConvert myfile.layout\n");
	printf("  BinLayoutConvert --backup ./layouts/\n");
	printf("  BinLayoutConvert --parallel --threads=4 ./layouts/\n");
}

bool isAFilename(const char* sz)
{
	DWORD attr = GetFileAttributes(sz);
	if (INVALID_FILE_ATTRIBUTES == attr)
	{
		return false;
	}

	return (attr & FILE_ATTRIBUTE_DIRECTORY) == 0;
}

bool isADirectory(const char* sz)
{
	DWORD attr = GetFileAttributes(sz);
	if (INVALID_FILE_ATTRIBUTES == attr)
	{
		return false;
	}

	return (attr & FILE_ATTRIBUTE_DIRECTORY) != 0;
}

// RAII wrapper for directory traversal handle, prevent handle leak
class FindHandle
{
public:
	explicit FindHandle(intptr_t h) : m_handle(h) {}
	~FindHandle() { if (m_handle != -1) _findclose(m_handle); }
	intptr_t get() const { return m_handle; }
	void release() { m_handle = -1; }
private:
	intptr_t m_handle;
	FindHandle(const FindHandle&);
	FindHandle& operator=(const FindHandle&);
};

void searchFilesInDir(const std::string& dir, const std::string& filePattern, std::vector<std::string>& fileArr)
{
	std::string fileSpec = dir + filePattern;

	_finddata_t fd;
	intptr_t hFind = _findfirst(fileSpec.c_str(), &fd);
	if (hFind == -1)
	{
		return;
	}

	FindHandle guard(hFind);

	do
	{
		if (0 != strcmp(fd.name, ".") && 0 != strcmp(fd.name, ".."))
		{
			if (fd.attrib & _A_SUBDIR)
			{
				searchFilesInDir(dir + fd.name + "/", filePattern, fileArr);
			}
			else
			{
				std::string filename = dir + fd.name;
				fileArr.push_back(filename);
			}
		}
	} while (_findnext(hFind, &fd) == 0);
}

Options parseOptions(int argc, const char* argv[], int& outPathIndex)
{
	Options opts;
	outPathIndex = -1;

	for (int i = 1; i < argc; ++i)
	{
		const char* arg = argv[i];

		if (strcmp(arg, "--backup") == 0)
		{
			opts.createBackup = true;
		}
		else if (strcmp(arg, "--parallel") == 0)
		{
			opts.parallelMode = true;
		}
		else if (strncmp(arg, "--threads=", 10) == 0)
		{
			opts.threadCount = atoi(arg + 10);
			if (opts.threadCount < 1) opts.threadCount = 1;
			if (opts.threadCount > 8) opts.threadCount = 8;
		}
		else if (strcmp(arg, "--legacy") == 0)
		{
			opts.legacyMode = true;
		}
		else if (strcmp(arg, "--help") == 0 || strcmp(arg, "-h") == 0 || strcmp(arg, "/?") == 0)
		{
			// Mark to show help
			outPathIndex = -2;
			return opts;
		}
		else if (arg[0] != '-')
		{
			outPathIndex = i;
		}
	}

	return opts;
}

int main(int argc, const char* argv[])
{
	CEGUI::DefaultLogger loger;
	CEGUI::BinLayout::g_RegSerializers_v1();

	int pathIndex = -1;
	Options opts = parseOptions(argc, argv, pathIndex);

	// Show help
	if (pathIndex == -2)
	{
		showHelp();
		return 0;
	}

	// No arguments or no path
	if (pathIndex < 0)
	{
		showHelp();
		return 1;
	}

	const char* inputPath = argv[pathIndex];

	if (isAFilename(inputPath))
	{
		// Single file conversion
		if (opts.legacyMode)
		{
			// Legacy mode (unsafe, for backward compatibility)
			printf("convert %s (legacy mode)\n", inputPath);
			CEGUI::BinLayout::XMLToBin xmlToBin;
			xmlToBin.convert(inputPath, inputPath);
		}
		else
		{
			// Safe mode
			printf("convert %s\n", inputPath);
			CEGUI::BinLayout::XMLToBin xmlToBin;
			std::string error;
			if (SafeIO::safeConvert(xmlToBin, inputPath, opts.createBackup, error))
			{
				printf("OK\n");
			}
			else
			{
				printf("FAILED: %s\n", error.c_str());
				return 1;
			}
		}
	}
	else if (isADirectory(inputPath))
	{
		// Batch directory conversion
		std::string rootDir = inputPath;
		char lastChar = rootDir[rootDir.size() - 1];
		if (lastChar != '/' && lastChar != '\\')
		{
			rootDir += "/";
		}

		std::vector<std::string> filenameArr;
		searchFilesInDir(rootDir, "*.layout", filenameArr);

		if (filenameArr.empty())
		{
			printf("No .layout files found in %s\n", rootDir.c_str());
			return 0;
		}

		printf("Found %zu files\n", filenameArr.size());

		if (opts.parallelMode && !opts.legacyMode)
		{
			// Multi-threaded mode
			std::vector<ParallelConvert::ConvertTask> tasks;
			tasks.reserve(filenameArr.size());
			for (size_t i = 0; i < filenameArr.size(); ++i)
			{
				ParallelConvert::ConvertTask task;
				task.path = filenameArr[i];
				task.createBackup = opts.createBackup;
				tasks.push_back(task);
			}
			ParallelConvert::runParallel(tasks, opts.threadCount);
		}
		else
		{
			// Serial mode
			int successCount = 0;
			int failCount = 0;
			size_t fileCount = filenameArr.size();

			for (size_t i = 0; i < fileCount; ++i)
			{
				const std::string& srcFilename = filenameArr[i];

				if (opts.legacyMode)
				{
					// Legacy mode (unsafe)
					printf("[%zu/%zu] convert %s (legacy)\n", i + 1, fileCount, srcFilename.c_str());
					CEGUI::BinLayout::XMLToBin xmlToBin;
					xmlToBin.convert(srcFilename, srcFilename);
					++successCount;
				}
				else
				{
					// Safe mode
					CEGUI::BinLayout::XMLToBin xmlToBin;
					std::string error;
					if (SafeIO::safeConvert(xmlToBin, srcFilename, opts.createBackup, error))
					{
						printf("[%zu/%zu] OK: %s\n", i + 1, fileCount, srcFilename.c_str());
						++successCount;
					}
					else
					{
						printf("[%zu/%zu] FAILED: %s (%s)\n", i + 1, fileCount, srcFilename.c_str(), error.c_str());
						++failCount;
					}
				}
			}

			printf("\nConversion complete: %d success, %d failed\n", successCount, failCount);
		}
	}
	else
	{
		printf("Error: '%s' is not a valid file or directory\n", inputPath);
		showHelp();
		return 1;
	}

	return 0;
}
