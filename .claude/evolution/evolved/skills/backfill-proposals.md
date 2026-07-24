# Skill Backfill Proposals

- Time: 2026-03-05 22:47:24
- Source instincts: E:\MT3\.claude\evolution\instincts\mt3-instincts.json
- Proposal count: 20

## Skill: android-build

- File: E:\MT3\.claude\skills\client\android-build.md
- [instinct-log.pattern::MSB] signal='log.pattern::MSB' confidence=0.81 action=Run toolchain preflight checks (VS2013/MSBuild12/JDK/NDK/Ant) before build.

## Skill: ant-build

- File: E:\MT3\.claude\skills\server\ant-build.md
- [instinct-log.pattern::MSB] signal='log.pattern::MSB' confidence=0.81 action=Run toolchain preflight checks (VS2013/MSBuild12/JDK/NDK/Ant) before build.

## Skill: build-troubleshooting

- File: E:\MT3\.claude\skills\common\build-troubleshooting.md
- [instinct-log.pattern::error-] signal='log.pattern::error ' confidence=0.84 action=Use first-error-first policy: inspect the first error with 30 lines of context.
- [instinct-log.pattern::Exception] signal='log.pattern::Exception' confidence=0.84 action=Keep as observation rule and wait for more samples before promotion.
- [instinct-log.pattern::LNK] signal='log.pattern::LNK' confidence=0.95 action=Check PlatformToolset=v120, library link order, and prebuilt ABI compatibility first.
- [instinct-log.pattern::MSB] signal='log.pattern::MSB' confidence=0.81 action=Run toolchain preflight checks (VS2013/MSBuild12/JDK/NDK/Ant) before build.

## Skill: continuous-learning-v2

- File: E:\MT3\.claude\skills\common\continuous-learning-v2.md
- [instinct-log.pattern::-] signal='log.pattern::错误' confidence=0.81 action=Keep as observation rule and wait for more samples before promotion.
- [instinct-logs.file_count] signal='logs.file_count' confidence=0.76 action=Keep as observation rule and wait for more samples before promotion.
- [instinct-git.commit_count] signal='git.commit_count' confidence=0.64 action=Keep as observation rule and wait for more samples before promotion.

## Skill: debugging

- File: E:\MT3\.claude\skills\common\debugging.md
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-11--345-257-271-351-275-220-346-223-215-344-275-234-346-214-207-345-215-227__Alignment-Operations-Guide.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/11-\345\257\271\351\275\220\346\223\215\344\275\234\346\214\207\345\215\227__Alignment-Operations-Guide.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-05--347-274-226-350-257-221-346-236-204-345-273-272-346-214-207-345-215-227Build_Guide.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/05-\347\274\226\350\257\221\346\236\204\345\273\272\346\214\207\345\215\227Build_Guide.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-CopiedSelection.cpp] signal='git.hotfile::tools/CELayoutEditor/src/CopiedSelection.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-WindowBox.cpp] signal='git.hotfile::tools/CELayoutEditor/src/WindowBox.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogAbout.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogAbout.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-inc-StringHelper.h] signal='git.hotfile::tools/CELayoutEditor/inc/StringHelper.h' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogAddWindow.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogAddWindow.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-log.pattern::error-] signal='log.pattern::error ' confidence=0.84 action=Use first-error-first policy: inspect the first error with 30 lines of context.
- [instinct-log.pattern::Exception] signal='log.pattern::Exception' confidence=0.84 action=Keep as observation rule and wait for more samples before promotion.
- [instinct-git.hotfile::tools-CELayoutEditor-vc-12-CELayoutEditor.vcxproj] signal='git.hotfile::tools/CELayoutEditor/vc++12/CELayoutEditor.vcxproj' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-inc-BuildChecks.h] signal='git.hotfile::tools/CELayoutEditor/inc/BuildChecks.h' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-00--346-226-207-346-241-243-345-256-241-350-256-241-346-212-245-345-221-212__Documentation-Audit-Report.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/00-\346\226\207\346\241\243\345\256\241\350\256\241\346\212\245\345\221\212__Documentation-Audit-Report.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-EditorFrame.cpp] signal='git.hotfile::tools/CELayoutEditor/src/EditorFrame.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogMain.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogMain.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-EditorDocument.cpp] signal='git.hotfile::tools/CELayoutEditor/src/EditorDocument.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.

## Skill: dependency-management

- File: E:\MT3\.claude\skills\common\dependency-management.md
- [instinct-log.pattern::LNK] signal='log.pattern::LNK' confidence=0.95 action=Check PlatformToolset=v120, library link order, and prebuilt ABI compatibility first.

## Skill: git-workflow

- File: E:\MT3\.claude\skills\common\git-workflow.md
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-11--345-257-271-351-275-220-346-223-215-344-275-234-346-214-207-345-215-227__Alignment-Operations-Guide.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/11-\345\257\271\351\275\220\346\223\215\344\275\234\346\214\207\345\215\227__Alignment-Operations-Guide.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-05--347-274-226-350-257-221-346-236-204-345-273-272-346-214-207-345-215-227Build_Guide.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/05-\347\274\226\350\257\221\346\236\204\345\273\272\346\214\207\345\215\227Build_Guide.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-CopiedSelection.cpp] signal='git.hotfile::tools/CELayoutEditor/src/CopiedSelection.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-WindowBox.cpp] signal='git.hotfile::tools/CELayoutEditor/src/WindowBox.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogAbout.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogAbout.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-inc-StringHelper.h] signal='git.hotfile::tools/CELayoutEditor/inc/StringHelper.h' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogAddWindow.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogAddWindow.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-vc-12-CELayoutEditor.vcxproj] signal='git.hotfile::tools/CELayoutEditor/vc++12/CELayoutEditor.vcxproj' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-inc-BuildChecks.h] signal='git.hotfile::tools/CELayoutEditor/inc/BuildChecks.h' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::-tools-CELayoutEditor-docs-00--346-226-207-346-241-243-345-256-241-350-256-241-346-212-245-345-221-212__Documentation-Audit-Report.md-] signal='git.hotfile::"tools/CELayoutEditor/docs/00-\346\226\207\346\241\243\345\256\241\350\256\241\346\212\245\345\221\212__Documentation-Audit-Report.md"' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-EditorFrame.cpp] signal='git.hotfile::tools/CELayoutEditor/src/EditorFrame.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-DialogMain.cpp] signal='git.hotfile::tools/CELayoutEditor/src/DialogMain.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.
- [instinct-git.hotfile::tools-CELayoutEditor-src-EditorDocument.cpp] signal='git.hotfile::tools/CELayoutEditor/src/EditorDocument.cpp' confidence=0.62 action=Add high-churn files to focused review checklist with regression validation.

## Skill: windows-build

- File: E:\MT3\.claude\skills\client\windows-build.md
- [instinct-log.pattern::LNK] signal='log.pattern::LNK' confidence=0.95 action=Check PlatformToolset=v120, library link order, and prebuilt ABI compatibility first.
- [instinct-log.pattern::MSB] signal='log.pattern::MSB' confidence=0.81 action=Run toolchain preflight checks (VS2013/MSBuild12/JDK/NDK/Ant) before build.
