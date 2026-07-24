#include "../include/SLJFP_WorkflowPresenter.h"
#include "../include/SLJFP_ErrorCodes.h"

#include <algorithm>
#include <iomanip>
#include <map>
#include <set>
#include <sstream>

#ifdef _WIN32
#define NOMINMAX
#include <windows.h>
#endif

namespace SLJFP {

namespace {

std::wstring MultiByteToWideBestEffort(const std::string& value) {
#ifdef _WIN32
    if (value.empty()) {
        return std::wstring();
    }

    UINT codePage = CP_UTF8;
    DWORD flags = MB_ERR_INVALID_CHARS;
    int required = MultiByteToWideChar(codePage, flags, value.c_str(), -1, NULL, 0);
    if (required <= 0) {
        codePage = CP_ACP;
        flags = 0;
        required = MultiByteToWideChar(codePage, flags, value.c_str(), -1, NULL, 0);
        if (required <= 0) {
            return std::wstring();
        }
    }

    std::wstring wide(required, L'\0');
    if (MultiByteToWideChar(codePage, flags, value.c_str(), -1, &wide[0], required) <= 0) {
        return std::wstring();
    }
    if (!wide.empty() && wide.back() == L'\0') {
        wide.pop_back();
    }
    return wide;
#else
    return std::wstring(value.begin(), value.end());
#endif
}

std::wstring FormatBytes(uint64_t bytes) {
    const double kb = static_cast<double>(bytes) / 1024.0;
    const double mb = kb / 1024.0;
    const double gb = mb / 1024.0;

    std::wostringstream oss;
    if (gb >= 1.0) {
        oss << std::fixed << std::setprecision(2) << gb << L" GB";
    } else if (mb >= 1.0) {
        oss << std::fixed << std::setprecision(2) << mb << L" MB";
    } else if (kb >= 1.0) {
        oss << std::fixed << std::setprecision(2) << kb << L" KB";
    } else {
        oss << bytes << L" B";
    }
    return oss.str();
}

std::wstring FormatRate(uint32_t rateBasis) {
    std::wostringstream oss;
    oss << (rateBasis / 100) << L"." << std::setw(2) << std::setfill(L'0') << (rateBasis % 100) << L"%";
    return oss.str();
}

std::wstring FormatCRC32(uint32_t value) {
    std::wostringstream oss;
    oss << L"0x" << std::uppercase << std::hex << std::setw(8) << std::setfill(L'0') << value;
    return oss.str();
}

std::wstring DescribeDecryptMode(DecryptMode mode) {
    switch (mode) {
        case DecryptMode::LJFilePackSMS4:
            return L"LJFilePack-SMS4";
        case DecryptMode::ApkClientObf:
            return L"APK-ClientObf";
        case DecryptMode::Auto:
        default:
            return L"Auto";
    }
}

std::wstring FormatErrorCode(int code) {
    if (code == 0) {
        return L"无错误";
    }

    std::wostringstream oss;
    oss << code << L" (" << GetErrorMessage(static_cast<ErrorCode>(code)) << L")";
    return oss.str();
}

std::wstring BuildDecryptDiagnosticSummary(const DecryptFailureDiagnostic& diagnostic) {
    std::wostringstream oss;
    oss << L"文件 #" << diagnostic.fileIndex
        << L"，输入 " << FormatBytes(diagnostic.inputSize)
        << L"，最终错误 " << FormatErrorCode(diagnostic.failureCode);
    if (!diagnostic.candidates.empty()) {
        const DecryptProbeRecord& candidate = diagnostic.candidates.back();
        oss << L"；最近候选 "
            << MultiByteToWideBestEffort(candidate.candidateId)
            << L" / " << DescribeDecryptMode(candidate.mode)
            << L" / CRC "
            << (candidate.crcChecked ? (candidate.crcMatched ? L"命中" : L"失配") : L"未校验");
    }
    return oss.str();
}

std::wstring FormatFileIndexLabel(uint32_t fileIndex) {
    std::wostringstream oss;
    oss << L"文件 #" << fileIndex;
    return oss.str();
}

void DedupeIndices(std::vector<size_t>& indices) {
    std::sort(indices.begin(), indices.end());
    indices.erase(std::unique(indices.begin(), indices.end()), indices.end());
}

void FinalizeIssueGroup(WorkflowPresenter::ReviewIssueGroup& group) {
    DedupeIndices(group.fileIndices);
    group.filterable = !group.fileIndices.empty();
    if (group.primaryFileIndex < 0 && !group.fileIndices.empty()) {
        group.primaryFileIndex = static_cast<long>(group.fileIndices.front());
    }
    if (group.filterLabel.empty()) {
        group.filterLabel = group.subject;
    }
}

std::wstring ToWidePath(const std::string& value) {
    return value.empty() ? std::wstring() : MultiByteToWideBestEffort(value);
}

WorkflowPresenter::ReviewIssueGroup MakeIssueGroup(const wchar_t* key,
                                                   const wchar_t* category,
                                                   const std::wstring& subject,
                                                   const std::wstring& detail) {
    WorkflowPresenter::ReviewIssueGroup group;
    group.key = key;
    group.category = category;
    group.subject = subject;
    group.detail = detail;
    return group;
}

} // namespace

WorkflowPresenter::ReviewIssueGroup::ReviewIssueGroup()
    : primaryFileIndex(-1)
    , rerunnable(false)
    , filterable(false) {
}

WorkflowPresenter::ReviewPanelModel::ReviewPanelModel()
    : canLocate(false) {
}

WorkflowPresenter::ReviewPanelModel WorkflowPresenter::BuildReviewPanelModel(
    const WorkflowSessionController& session,
    const Unpacker* unpacker,
    const std::wstring& activeReviewFilterLabel) {
    ReviewPanelModel model;

    const WorkflowSessionController::SourceState& source = session.GetSourceState();
    const WorkflowSessionController::MappingState& mapping = session.GetMappingState();
    const WorkflowSessionController::ExecutionState& execution = session.GetExecutionState();
    const WorkflowSessionController::RunState& run = session.GetRunState();
    const WorkflowSessionController::ReviewState& review = session.GetReviewState();

    const std::vector<FailedFileRecord> failedFiles = unpacker
        ? unpacker->GetLastFailedFiles()
        : std::vector<FailedFileRecord>();
    const std::vector<OutputPathManifestRecord> manifestRecords = unpacker
        ? unpacker->GetLastOutputPathManifestRecords()
        : std::vector<OutputPathManifestRecord>();

    std::wostringstream summary;
    summary << L"[闭环状态]\n";
    if (!source.loaded) {
        summary << L"源数据尚未加载，结果审阅会在打开索引后自动提供映射建议与失败诊断。\n";
    } else {
        summary << L"源数据: " << source.totalFiles << L" 个文件 / " << FormatBytes(source.totalBytes) << L"\n";
        if (!mapping.loaded) {
            summary << L"映射健康: 尚未加载映射，建议先补全再执行。\n";
        } else if (mapping.hasHitRate) {
            summary << L"映射健康: " << FormatRate(mapping.rateBasis)
                    << L" (" << mapping.hitCount << L"/" << mapping.totalCount << L")\n";
        } else {
            summary << L"映射健康: 已加载 " << mapping.mappingCount << L" 条映射，等待统计\n";
        }

        if (!mapping.guidance.empty()) {
            summary << L"建议: " << ToWidePath(mapping.guidance) << L"\n";
        }

        summary << L"输出目录: "
                << (execution.outputReady ? ToWidePath(execution.outputDir) : std::wstring(L"尚未设置"))
                << L"\n";
    }

    if (run.running) {
        summary << L"执行状态: "
                << (run.paused ? L"已暂停" : (run.stopping ? L"正在停止" : L"进行中"))
                << L" (" << run.currentCount << L"/" << run.totalCount << L")\n";
    } else if (run.finished) {
        summary << L"最近结果: 成功 " << run.successCount << L" / 失败 " << run.failedCount << L"\n";
        if (execution.outputReady) {
            summary << L"路径清单: " << ToWidePath(execution.outputDir + "/unpack_path_manifest.tsv") << L"\n";
        }
    } else {
        summary << L"执行状态: 尚未运行，可以先检查映射健康与输出目录。\n";
    }

    if (review.available && review.firstErrorCode != 0) {
        summary << L"首个错误: " << FormatErrorCode(review.firstErrorCode) << L"\n";
        if (!review.firstErrorPath.empty()) {
            summary << L"失败样本: " << ToWidePath(review.firstErrorPath) << L"\n";
        }
    }
    if (review.hasDecryptDiagnostic) {
        summary << L"解密诊断: " << BuildDecryptDiagnosticSummary(review.decryptDiagnostic) << L"\n";
    }
    if (!activeReviewFilterLabel.empty()) {
        summary << L"联动筛选: " << activeReviewFilterLabel << L"\n";
    }
    model.summary = summary.str();

    if (!source.loaded) {
        model.groups.push_back(MakeIssueGroup(L"prepare:no_source", L"准备项", L"尚未加载索引", L"先打开源数据或索引文件"));
    } else {
        if (!mapping.loaded) {
            model.groups.push_back(MakeIssueGroup(L"mapping:not_loaded",
                                                  L"映射建议",
                                                  L"尚未加载映射",
                                                  L"建议使用“补全映射”或手动加载映射，以减少 CRC 命名输出"));
        } else if (mapping.needsAttention) {
            ReviewIssueGroup group = MakeIssueGroup(
                L"mapping:needs_attention",
                L"映射建议",
                mapping.hasHitRate ? (std::wstring(L"命中率 ") + FormatRate(mapping.rateBasis)) : std::wstring(L"映射待复核"),
                mapping.guidance.empty() ? std::wstring(L"建议补全映射后再执行") : ToWidePath(mapping.guidance));
            group.filterLabel = L"映射缺口";
            group.rerunnable = true;
            if (unpacker != NULL) {
                for (size_t i = 0; i < mapping.missingSamples.size(); ++i) {
                    const int fileIndex = unpacker->FindFileByCRC32(mapping.missingSamples[i]);
                    if (fileIndex >= 0) {
                        group.fileIndices.push_back(static_cast<size_t>(fileIndex));
                    }
                }
            }
            FinalizeIssueGroup(group);
            model.groups.push_back(group);
        }

        if (!execution.outputReady) {
            model.groups.push_back(MakeIssueGroup(L"execution:no_output",
                                                  L"执行建议",
                                                  L"尚未设置输出目录",
                                                  L"设置输出目录后才能完整落盘并生成路径清单"));
        }
    }

    if (run.running) {
        std::wostringstream detail;
        detail << L"当前进度 " << run.currentCount << L"/" << run.totalCount;
        model.groups.push_back(MakeIssueGroup(L"run:active",
                                              L"运行状态",
                                              run.paused ? L"已暂停" : (run.stopping ? L"正在停止" : L"进行中"),
                                              detail.str()));
    } else if (run.finished) {
        std::wostringstream resultDetail;
        resultDetail << L"成功 " << run.successCount << L" / 失败 " << run.failedCount;
        model.groups.push_back(MakeIssueGroup(L"run:summary",
                                              L"执行结果",
                                              run.failedCount == 0 ? L"最近一次解包已完成" : L"最近一次解包包含失败项",
                                              resultDetail.str()));

        if (!failedFiles.empty()) {
            std::wostringstream subject;
            subject << L"全部失败项 (" << static_cast<unsigned long long>(failedFiles.size()) << L")";
            ReviewIssueGroup allFailedGroup = MakeIssueGroup(L"failure:all",
                                                             L"失败文件",
                                                             subject.str(),
                                                             L"可批量导出、联动筛选并按当前集合复跑");
            allFailedGroup.filterLabel = L"全部失败项";
            allFailedGroup.rerunnable = true;
            for (size_t i = 0; i < failedFiles.size(); ++i) {
                allFailedGroup.fileIndices.push_back(static_cast<size_t>(failedFiles[i].fileIndex));
            }
            FinalizeIssueGroup(allFailedGroup);
            model.groups.push_back(allFailedGroup);
        }

        std::map<int, std::vector<size_t> > failedByErrorCode;
        for (size_t i = 0; i < failedFiles.size(); ++i) {
            failedByErrorCode[failedFiles[i].errorCode].push_back(static_cast<size_t>(failedFiles[i].fileIndex));
        }
        for (std::map<int, std::vector<size_t> >::const_iterator it = failedByErrorCode.begin();
             it != failedByErrorCode.end();
             ++it) {
            std::wostringstream detail;
            detail << L"共 " << static_cast<unsigned long long>(it->second.size())
                   << L" 个失败文件，可直接筛选并复跑该问题类型";
            ReviewIssueGroup group = MakeIssueGroup(L"", L"错误码统计", FormatErrorCode(it->first), detail.str());
            {
                std::wostringstream key;
                key << L"failure:error:" << it->first;
                group.key = key.str();
            }
            {
                std::wostringstream label;
                label << L"错误码 " << it->first;
                group.filterLabel = label.str();
            }
            group.fileIndices = it->second;
            group.rerunnable = true;
            FinalizeIssueGroup(group);
            model.groups.push_back(group);
        }

        if (review.available && review.firstErrorCode != 0) {
            ReviewIssueGroup group = MakeIssueGroup(
                L"failure:first",
                L"首个失败",
                review.firstErrorPath.empty()
                    ? FormatFileIndexLabel(review.firstErrorFileIndex)
                    : ToWidePath(review.firstErrorPath),
                std::wstring(L"错误 ") + FormatErrorCode(review.firstErrorCode));
            if (review.firstErrorFileIndex != static_cast<uint32_t>(-1)) {
                group.primaryFileIndex = static_cast<long>(review.firstErrorFileIndex);
                group.fileIndices.push_back(static_cast<size_t>(review.firstErrorFileIndex));
                group.rerunnable = true;
            }
            FinalizeIssueGroup(group);
            model.groups.push_back(group);
        }

        if (review.hasDecryptDiagnostic) {
            ReviewIssueGroup group = MakeIssueGroup(
                L"failure:decrypt_diagnostic",
                L"解密诊断",
                review.firstErrorPath.empty()
                    ? FormatFileIndexLabel(review.decryptDiagnostic.fileIndex)
                    : ToWidePath(review.firstErrorPath),
                BuildDecryptDiagnosticSummary(review.decryptDiagnostic));
            group.primaryFileIndex = static_cast<long>(review.decryptDiagnostic.fileIndex);
            group.fileIndices.push_back(static_cast<size_t>(review.decryptDiagnostic.fileIndex));
            group.rerunnable = true;
            FinalizeIssueGroup(group);
            model.groups.push_back(group);
        }

        std::map<std::wstring, std::vector<size_t> > manifestGroups;
        if (unpacker != NULL) {
            for (size_t i = 0; i < manifestRecords.size(); ++i) {
                const int fileIndex = unpacker->FindFileByCRC32(manifestRecords[i].pathCRC32);
                if (fileIndex < 0) {
                    continue;
                }

                const size_t indexValue = static_cast<size_t>(fileIndex);
                if (manifestRecords[i].mappingSanitized) {
                    manifestGroups[L"manifest:mapping_sanitized"].push_back(indexValue);
                }
                if (manifestRecords[i].conflictResolved) {
                    manifestGroups[L"manifest:conflict_suffix"].push_back(indexValue);
                }
                if (manifestRecords[i].existingTargetPreserved) {
                    manifestGroups[L"manifest:existing_target_preserved"].push_back(indexValue);
                }
                if (manifestRecords[i].postProcessMoved) {
                    manifestGroups[L"manifest:postprocess_relocated"].push_back(indexValue);
                }
                if (manifestRecords[i].reviewBucketed) {
                    manifestGroups[L"manifest:review_bucketed"].push_back(indexValue);
                }
            }
        }

        struct ManifestGroupDescriptor {
            const wchar_t* key;
            const wchar_t* subject;
            const wchar_t* detail;
        };

        static const ManifestGroupDescriptor kManifestDescriptors[] = {
            {L"manifest:mapping_sanitized", L"路径已清洗", L"映射路径含非法字符或危险片段，已自动改写"},
            {L"manifest:conflict_suffix", L"冲突已消解", L"存在同名目标，已追加稳定后缀"},
            {L"manifest:existing_target_preserved", L"保留既有目标", L"目标文件已存在且内容一致，未重复覆盖"},
            {L"manifest:postprocess_relocated", L"后处理已迁移", L"解包后被整理到新的最终路径"},
            {L"manifest:review_bucketed", L"进入 review 桶", L"仍需人工复核的文件已归档到 review/unresolved"}
        };

        for (size_t i = 0; i < sizeof(kManifestDescriptors) / sizeof(kManifestDescriptors[0]); ++i) {
            std::map<std::wstring, std::vector<size_t> >::const_iterator it =
                manifestGroups.find(kManifestDescriptors[i].key);
            if (it == manifestGroups.end() || it->second.empty()) {
                continue;
            }

            std::wostringstream subject;
            subject << kManifestDescriptors[i].subject << L" ("
                    << static_cast<unsigned long long>(it->second.size()) << L")";
            ReviewIssueGroup group = MakeIssueGroup(kManifestDescriptors[i].key,
                                                    L"Manifest 标记",
                                                    subject.str(),
                                                    kManifestDescriptors[i].detail);
            group.filterLabel = kManifestDescriptors[i].subject;
            group.fileIndices = it->second;
            group.rerunnable = true;
            FinalizeIssueGroup(group);
            model.groups.push_back(group);
        }

        if (execution.outputReady) {
            model.groups.push_back(MakeIssueGroup(L"artifact:manifest",
                                                  L"结果产物",
                                                  ToWidePath(execution.outputDir),
                                                  L"已写出输出目录与路径清单，可打开目录做复盘"));
        }
    }

    if (model.groups.empty()) {
        model.groups.push_back(MakeIssueGroup(L"status:clear",
                                              L"当前状态",
                                              L"暂无阻塞项",
                                              L"可以继续浏览文件、调整配置或执行解包"));
    }

    for (size_t i = 0; i < model.groups.size(); ++i) {
        FinalizeIssueGroup(model.groups[i]);
        if (model.groups[i].primaryFileIndex >= 0 || !model.groups[i].fileIndices.empty()) {
            model.canLocate = true;
        }
    }

    if (!model.canLocate &&
        review.available &&
        review.firstErrorFileIndex != static_cast<uint32_t>(-1)) {
        model.canLocate = true;
    }

    return model;
}

WorkflowPresenter::OverviewPanelModel WorkflowPresenter::BuildOverviewPanelModel(
    const WorkflowSessionController& session,
    const std::wstring& activeReviewFilterLabel) {
    OverviewPanelModel model;

    const WorkflowSessionController::SourceState& source = session.GetSourceState();
    const WorkflowSessionController::MappingState& mapping = session.GetMappingState();
    const WorkflowSessionController::ExecutionState& execution = session.GetExecutionState();
    const WorkflowSessionController::RunState& run = session.GetRunState();
    const WorkflowSessionController::ReviewState& review = session.GetReviewState();
    const WorkflowSessionController::PreviewState& preview = session.GetPreviewState();

    std::wostringstream overview;
    overview << L"[源数据]\n";
    if (source.loaded) {
        overview << L"索引: " << (source.indexPath.empty() ? std::wstring(L"(未记录)") : ToWidePath(source.indexPath)) << L"\n";
        overview << L"输入目录: " << (source.inputDir.empty() ? std::wstring(L"(未记录)") : ToWidePath(source.inputDir)) << L"\n";
        overview << L"资源规模: " << source.totalFiles << L" 个文件 / " << FormatBytes(source.totalBytes) << L"\n";
    } else {
        overview << L"尚未加载索引，请先打开资源目录或索引文件。\n";
    }

    overview << L"\n[映射健康]\n";
    overview << L"映射条目: " << mapping.mappingCount << L"\n";
    if (mapping.hasHitRate) {
        overview << L"命中率: " << FormatRate(mapping.rateBasis)
                 << L" (" << mapping.hitCount << L"/" << mapping.totalCount << L")\n";
    } else {
        overview << L"命中率: 尚未加载映射，未命中资源将按 CRC / 推断路径输出。\n";
    }
    if (!mapping.mappingPath.empty()) {
        overview << L"最近映射: " << ToWidePath(mapping.mappingPath) << L"\n";
    } else if (!mapping.generatedPath.empty()) {
        overview << L"最近生成: " << ToWidePath(mapping.generatedPath) << L"\n";
    }
    if (!mapping.guidance.empty()) {
        overview << L"建议: " << ToWidePath(mapping.guidance) << L"\n";
    }
    if (!mapping.missingSamples.empty()) {
        overview << L"缺口样本: ";
        const size_t sampleCount = std::min<size_t>(mapping.missingSamples.size(), 4u);
        for (size_t i = 0; i < sampleCount; ++i) {
            if (i > 0) {
                overview << L", ";
            }
            overview << FormatCRC32(mapping.missingSamples[i]);
        }
        overview << L"\n";
    }

    overview << L"\n[执行计划]\n";
    overview << L"输出目录: " << (execution.outputReady ? ToWidePath(execution.outputDir) : std::wstring(L"尚未设置")) << L"\n";
    overview << L"线程数: " << (execution.options.threadCount > 0 ? execution.options.threadCount : 1)
             << L" | CRC 校验: " << (execution.options.verifyCRC32 ? L"开" : L"关")
             << L" | 流式模式: " << (execution.options.useStreamMode ? L"开" : L"关") << L"\n";
    overview << L"覆盖已存在: " << (execution.options.overwriteExisting ? L"是" : L"否")
             << L" | 按类型归类: " << (execution.options.organizeByType ? L"是" : L"否") << L"\n";

    overview << L"\n[结果审阅]\n";
    if (run.running) {
        overview << L"当前状态: "
                 << (run.paused ? L"已暂停" : (run.stopping ? L"正在停止" : L"进行中"))
                 << L" (" << run.currentCount << L"/" << run.totalCount << L")\n";
    } else if (run.finished) {
        overview << L"最近结果: 成功 " << run.successCount << L" / 失败 " << run.failedCount;
        if (!run.summary.empty()) {
            overview << L"\n" << ToWidePath(run.summary);
        }
        overview << L"\n";
    } else {
        overview << L"尚未执行解包，完成执行后这里会展示结果摘要。\n";
    }

    if (review.available && review.firstErrorCode != 0) {
        overview << L"首个错误: " << FormatErrorCode(review.firstErrorCode) << L"\n";
        if (!review.firstErrorPath.empty()) {
            overview << L"失败样本: " << ToWidePath(review.firstErrorPath) << L"\n";
        }
    }
    if (review.hasDecryptDiagnostic) {
        overview << L"解密诊断: " << BuildDecryptDiagnosticSummary(review.decryptDiagnostic) << L"\n";
    }
    if (!activeReviewFilterLabel.empty()) {
        overview << L"联动筛选: " << activeReviewFilterLabel << L"\n";
    }

    if (preview.selected) {
        overview << L"\n[当前选中]\n"
                 << ToWidePath(preview.displayPath) << L"\n"
                 << L"映射命中: " << (preview.mappingHit ? L"是" : L"否")
                 << L" | 预估输出: "
                 << (preview.outputPath.empty() ? std::wstring(L"尚未生成") : ToWidePath(preview.outputPath))
                 << L"\n";
    }

    model.text = overview.str();
    return model;
}

WorkflowPresenter::StatusBarModel WorkflowPresenter::BuildStatusBarModel(
    const WorkflowSessionController& session,
    const Unpacker* unpacker,
    bool hasLoadedIndex,
    bool isUnpacking,
    long visibleFiles,
    const std::wstring& activeReviewFilterLabel) {
    StatusBarModel model;
    const uint32_t totalFiles = unpacker
        ? unpacker->GetTotalFiles()
        : session.GetSourceState().totalFiles;
    if (visibleFiles >= 0 && static_cast<uint32_t>(visibleFiles) != totalFiles) {
        std::wostringstream oss;
        oss << L"文件: " << visibleFiles << L" / " << totalFiles;
        model.fileCountText = oss.str();
    } else {
        std::wostringstream oss;
        oss << L"文件: " << totalFiles;
        model.fileCountText = oss.str();
    }

    const WorkflowSessionController::RunState& runState = session.GetRunState();
    if (runState.running) {
        if (runState.paused) {
            model.primaryText = L"已暂停，等待继续";
        } else if (runState.stopping) {
            model.primaryText = L"正在停止当前会话";
        } else {
            model.primaryText = L"解包会话运行中";
        }
    } else if (runState.finished) {
        model.primaryText = (runState.result == LJFP_SUCCESS)
            ? L"结果已生成，可继续审阅"
            : L"结果已生成，请审阅失败项";
    } else if (!hasLoadedIndex) {
        model.primaryText = L"等待加载源数据";
    } else if (unpacker != NULL && unpacker->GetPathMappingCount() == 0) {
        model.primaryText = L"源数据已就绪，建议补充路径映射";
    } else if (!session.GetExecutionState().outputReady) {
        model.primaryText = L"映射已就绪，等待设置输出目录";
    } else {
        model.primaryText = L"执行计划已就绪";
    }

    if (isUnpacking) {
        return model;
    }

    if (!activeReviewFilterLabel.empty()) {
        model.secondaryText = std::wstring(L"联动筛选: ") + activeReviewFilterLabel;
        return model;
    }

    uint32_t hit = 0;
    uint32_t total = 0;
    uint32_t rateBasis = 0;
    if (unpacker != NULL && unpacker->GetPathMappingHitRate(hit, total, rateBasis)) {
        std::wostringstream oss;
        oss << L"映射命中: " << FormatRate(rateBasis) << L" (" << hit << L"/" << total << L")";
        model.secondaryText = oss.str();
        return model;
    }

    const WorkflowSessionController::TreeFilter& filter = session.GetFilter();
    switch (filter.mode) {
        case WorkflowSessionController::TreeFilterMode::LooseFiles:
            model.secondaryText = L"当前过滤: 散文件";
            break;
        case WorkflowSessionController::TreeFilterMode::PackFiles: {
            std::wostringstream oss;
            oss << L"当前过滤: 包 " << filter.packIndex;
            model.secondaryText = oss.str();
            break;
        }
        case WorkflowSessionController::TreeFilterMode::MappedFiles:
            model.secondaryText = L"当前过滤: 已命中映射";
            break;
        case WorkflowSessionController::TreeFilterMode::UnmappedFiles:
            model.secondaryText = L"当前过滤: 待补全映射";
            break;
        case WorkflowSessionController::TreeFilterMode::AllFiles:
        default:
            model.secondaryText.clear();
            break;
    }

    return model;
}

std::string WorkflowPresenter::BuildPreviewOutputPath(
    const WorkflowSessionController& session,
    const Unpacker* unpacker,
    size_t fileIndex) {
    if (unpacker == NULL || fileIndex >= unpacker->GetFileList().size()) {
        return std::string();
    }

    const WorkflowSessionController::ExecutionState& execution = session.GetExecutionState();
    if (!execution.outputReady || execution.outputDir.empty()) {
        return std::string();
    }

    const std::string displayPath = unpacker->GetFilePath(fileIndex);
    if (displayPath.empty()) {
        return std::string();
    }

    std::string normalizedPath = displayPath;
    for (size_t i = 0; i < normalizedPath.size(); ++i) {
        if (normalizedPath[i] == '\\') {
            normalizedPath[i] = '/';
        }
    }

    if (execution.options.preferPathMapping && unpacker->HasPathMappingForFile(fileIndex)) {
        return execution.outputDir + "/" + normalizedPath;
    }

    if (execution.options.organizeByType) {
        return execution.outputDir + "/unknown/" + normalizedPath;
    }

    return execution.outputDir + "/" + normalizedPath;
}

} // namespace SLJFP
