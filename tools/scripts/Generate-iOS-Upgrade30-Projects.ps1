[CmdletBinding()]
param(
    [string]$RepoRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-MT3RepoRoot {
    param([string]$RequestedRoot)

    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return (Resolve-Path -LiteralPath $RequestedRoot).Path
    }

    $root = (& git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
        throw "MT3 repository root was not found."
    }
    return (Resolve-Path -LiteralPath $root.Trim()).Path
}

function Read-Utf8Text {
    param([string]$Path)

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8NoBomCrlf {
    param(
        [string]$Path,
        [string]$Text
    )

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    $normalized = $Text -replace "`r?`n", "`r`n"
    [System.IO.File]::WriteAllText(
        $Path,
        $normalized,
        (New-Object System.Text.UTF8Encoding($false)))
}

function Get-PbxIdentifier {
    param(
        [string]$Prefix,
        [string]$Key
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
        $hex = ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "")
        return ($Prefix + $hex).Substring(0, 24).ToUpperInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Add-Upgrade30Definitions {
    param([string]$Text)

    $arrayPattern = 'GCC_PREPROCESSOR_DEFINITIONS = \((?<body>.*?)\);'
    $Text = [regex]::Replace(
        $Text,
        $arrayPattern,
        {
            param($match)
            if ($match.Groups['body'].Value -match 'MT3_COCOS2D_X_3') {
                return $match.Value
            }

            return "GCC_PREPROCESSOR_DEFINITIONS = (`r`n" +
                "`t`t`t`t`tMT3_COCOS2D_X_3=1,`r`n" +
                "`t`t`t`t`tCEGUI_STATIC,`r`n" +
                $match.Groups['body'].Value + ");"
        },
        [System.Text.RegularExpressions.RegexOptions]::Singleline)

    $scalarPattern = '(?m)^(?<indent>\s*)GCC_PREPROCESSOR_DEFINITIONS = (?<value>[^\r\n;]+);$'
    return [regex]::Replace(
        $Text,
        $scalarPattern,
        {
            param($match)
            $indent = $match.Groups['indent'].Value
            $value = $match.Groups['value'].Value
            return $indent + "GCC_PREPROCESSOR_DEFINITIONS = (`r`n" +
                $indent + "`tMT3_COCOS2D_X_3=1,`r`n" +
                $indent + "`tCEGUI_STATIC,`r`n" +
                $indent + "`t$value,`r`n" +
                $indent + "`t" + '"$(inherited)",' + "`r`n" +
                $indent + ");"
        })
}

function Remove-PbxSourceItems {
    param(
        [string]$Text,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $escaped = [regex]::Escape($name)
        $pattern = '(?m)^.*?/\* ' + $escaped + '(?: in Sources)? \*/.*\r?\n'
        $Text = [regex]::Replace($Text, $pattern, '')
    }
    return $Text
}

function Add-PbxSources {
    param(
        [string]$Text,
        [string]$PhaseId,
        [object[]]$Sources,
        [string]$Scope
    )

    $buildLines = New-Object System.Collections.Generic.List[string]
    $referenceLines = New-Object System.Collections.Generic.List[string]
    $phaseLines = New-Object System.Collections.Generic.List[string]

    foreach ($source in $Sources) {
        $name = [string]$source.Name
        if ($Text -match ('/\* ' + [regex]::Escape($name) + ' in Sources \*/')) {
            continue
        }

        $fileId = Get-PbxIdentifier -Prefix "F0" -Key "$Scope|file|$($source.Path)"
        $buildId = Get-PbxIdentifier -Prefix "F1" -Key "$Scope|build|$($source.Path)"
        $buildLines.Add("`t`t$buildId /* $name in Sources */ = {isa = PBXBuildFile; fileRef = $fileId /* $name */; };")
        $referenceLines.Add("`t`t$fileId /* $name */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.cpp.cpp; name = $name; path = `"$($source.Path)`"; sourceTree = SOURCE_ROOT; };")
        $phaseLines.Add("`t`t`t`t$buildId /* $name in Sources */,")
    }

    if ($buildLines.Count -eq 0) {
        return $Text
    }

    $Text = $Text.Replace(
        "/* End PBXBuildFile section */",
        (($buildLines -join "`r`n") + "`r`n/* End PBXBuildFile section */"))
    $Text = $Text.Replace(
        "/* End PBXFileReference section */",
        (($referenceLines -join "`r`n") + "`r`n/* End PBXFileReference section */"))

    $phasePattern = '(?s)(\s*' + [regex]::Escape($PhaseId) + ' /\* Sources \*/ = \{.*?files = \(\r?\n)'
    $replacementLines = $phaseLines -join "`r`n"
    if (-not [regex]::IsMatch($Text, $phasePattern)) {
        throw "PBX source phase not found: $PhaseId"
    }

    $Text = [regex]::Replace(
        $Text,
        $phasePattern,
        {
            param($match)
            return $match.Groups[1].Value + $replacementLines + "`r`n"
        },
        1)
    return $Text
}

function New-FireClientUpgrade30Project {
    param([string]$Root)

    $source = Join-Path $Root "client/FireClient/FireClient.xcodeproj/project.pbxproj"
    $target = Join-Path $Root "client/FireClient/FireClient-Upgrade30.xcodeproj/project.pbxproj"
    $text = Read-Utf8Text $source

    $text = $text.Replace("../../dependencies/cegui/CEGUI.xcodeproj", "../ios/CEGUI-0.7.9-r5.xcodeproj")
    $text = $text.Replace("CEGUI.xcodeproj", "CEGUI-0.7.9-r5.xcodeproj")
    $text = $text.Replace("engine.xcodeproj", "engine-Upgrade30.xcodeproj")

    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua/cocos2dx_support/", "../../cocos2d-x-3.0-oh/cocos/scripting/lua-bindings/manual/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua/lua/", "../../cocos2d-x-3.0-oh/external/lua/lua/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua/tolua/", "../../cocos2d-x-3.0-oh/external/lua/tolua/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua", "../../cocos2d-x-3.0-oh/external/lua")
    $text = $text.Replace("../../cocos2d-x-2.2.6/CocosDenshion/include/", "../../cocos2d-x-3.0-oh/cocos/audio/include/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/CocosDenshion/ios/", "../ios/vendor/fmod/CocosDenshion/ios/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/external/fmod/ios/", "../ios/vendor/fmod/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/external/curl/prebuilt/ios/", "../../cocos2d-x-3.0-oh/external/curl/prebuilt/ios/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/include/", "../../cocos2d-x-3.0-oh/cocos/2d/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/platform/ios/", "../../cocos2d-x-3.0-oh/cocos/2d/platform/ios/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/platform/", "../../cocos2d-x-3.0-oh/cocos/2d/platform/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/kazmath/include/", "../../cocos2d-x-3.0-oh/cocos/math/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/", "../../cocos2d-x-3.0-oh/cocos/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/extensions", "../../cocos2d-x-3.0-oh/extensions")
    $text = $text.Replace("../../dependencies/cegui/CEGUI", "../../tools/CEGUI-0.7.9-r5/cegui")
    $text = $text.Replace("../../dependencies/CEGUI/CEGUI", "../../tools/CEGUI-0.7.9-r5/cegui")

    $text = $text.Replace("LuaCocos2d.cpp", "lua_cocos2dx_auto.cpp")
    $text = $text.Replace("LuaCocos2d.h", "lua_cocos2dx_auto.hpp")
    $text = $text.Replace("cocos/scripting/lua-bindings/manual/lua_cocos2dx_auto", "cocos/scripting/lua-bindings/auto/lua_cocos2dx_auto")
    $text = $text.Replace("tolua_fix.c", "tolua_fix.cpp")
    $text = $text.Replace("lastKnownFileType = sourcecode.c.c; name = tolua_fix.cpp", "lastKnownFileType = sourcecode.cpp.cpp; name = tolua_fix.cpp")
    $text = [regex]::Replace(
        $text,
        '4A1D1BCD162678C30007B942 /\* libcocos2dx\.a \*/ = \{[^\r\n]+',
        '4A1D1BCD162678C30007B942 /* libcocos2dx iOS.a */ = {isa = PBXFileReference; lastKnownFileType = archive.ar; name = "libcocos2dx iOS.a"; path = "libcocos2dx iOS.a"; sourceTree = BUILT_PRODUCTS_DIR; };')
    $text = $text.Replace("libcocos2dx.a", "libcocos2dx iOS.a")
    $text = Add-Upgrade30Definitions $text

    if ($text -match 'cocos2d-x-2\.2\.6|dependencies/cegui') {
        $legacyLines = @($text -split "`r?`n" |
            Where-Object { $_ -match 'cocos2d-x-2\.2\.6|dependencies/cegui' } |
            Select-Object -First 10)
        throw "FireClient Upgrade30 project still contains legacy engine inputs:`r`n$($legacyLines -join "`r`n")"
    }

    Write-Utf8NoBomCrlf -Path $target -Text $text
}

function New-EngineUpgrade30Project {
    param([string]$Root)

    $source = Join-Path $Root "engine/engine.xcodeproj/project.pbxproj"
    $target = Join-Path $Root "engine/engine-Upgrade30.xcodeproj/project.pbxproj"
    $text = Read-Utf8Text $source

    $text = $text.Replace("cocos2dx.xcodeproj", "cocos2d_libs.xcodeproj")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/proj.ios/cocos2d_libs.xcodeproj", "../cocos2d-x-3.0-oh/build/cocos2d_libs.xcodeproj")
    $text = $text.Replace("remoteGlobalIDString = 1551A33F158F2AB200E66CFE;", "remoteGlobalIDString = A07A4C241783777C0073F6A7;")
    $text = $text.Replace('remoteInfo = cocos2dx;', 'remoteInfo = "cocos2dx iOS";')
    $text = $text.Replace("libcocos2dx.a", "libcocos2dx iOS.a")
    $text = $text.Replace("../cocos2d-x-2.2.6/extensions", "../cocos2d-x-3.0-oh/cocos/editor-support")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/include/", "../cocos2d-x-3.0-oh/cocos/2d/")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/platform/ios/", "../cocos2d-x-3.0-oh/cocos/2d/platform/ios/")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/platform/", "../cocos2d-x-3.0-oh/cocos/2d/platform/")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/kazmath/include/", "../cocos2d-x-3.0-oh/cocos/math/")
    $text = $text.Replace("../cocos2d-x-2.2.6/cocos2dx/", "../cocos2d-x-3.0-oh/cocos/")

    $spineSources = @(
        @{ Name = "BoundingBoxAttachment.cpp"; Path = "../cocos2d-x-3.0-oh/cocos/editor-support/spine/BoundingBoxAttachment.cpp" },
        @{ Name = "Event.cpp"; Path = "../cocos2d-x-3.0-oh/cocos/editor-support/spine/Event.cpp" },
        @{ Name = "EventData.cpp"; Path = "../cocos2d-x-3.0-oh/cocos/editor-support/spine/EventData.cpp" },
        @{ Name = "MT3SpineDiagnostic.cpp"; Path = "../cocos2d-x-3.0-oh/cocos/editor-support/spine/MT3SpineDiagnostic.cpp" },
        @{ Name = "SkeletonBounds.cpp"; Path = "../cocos2d-x-3.0-oh/cocos/editor-support/spine/SkeletonBounds.cpp" }
    )
    $text = Add-PbxSources -Text $text -PhaseId "7B987297170BEFF10038DE4A" -Sources $spineSources -Scope "engine-upgrade30"
    $text = Add-Upgrade30Definitions $text

    if ($text -match 'cocos2d-x-2\.2\.6|extensions/libSpine') {
        throw "engine Upgrade30 project still contains legacy engine inputs."
    }

    Write-Utf8NoBomCrlf -Path $target -Text $text
}

function New-CeguiUpgrade30Project {
    param([string]$Root)

    $source = Join-Path $Root "dependencies/cegui/CEGUI.xcodeproj/project.pbxproj"
    $target = Join-Path $Root "client/ios/CEGUI-0.7.9-r5.xcodeproj/project.pbxproj"
    $text = Read-Utf8Text $source

    $text = $text.Replace("CEGUI/", "../../tools/CEGUI-0.7.9-r5/cegui/")
    $text = $text.Replace("CEGUI/include/", "../../tools/CEGUI-0.7.9-r5/cegui/include/")
    $text = $text.Replace("../pcre-8.31/", "../../dependencies/pcre-8.31/")
    $text = $text.Replace("../freetype-2.4.9/", "../../dependencies/freetype-2.4.9/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/include/", "../../cocos2d-x-3.0-oh/cocos/2d/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/platform/ios/", "../../cocos2d-x-3.0-oh/cocos/2d/platform/ios/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/platform/", "../../cocos2d-x-3.0-oh/cocos/2d/platform/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/kazmath/include/", "../../cocos2d-x-3.0-oh/cocos/math/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/cocos2dx/", "../../cocos2d-x-3.0-oh/cocos/")
    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua/tolua", "../../cocos2d-x-3.0-oh/external/lua/tolua")
    $text = $text.Replace("../../cocos2d-x-2.2.6/scripting/lua/lua", "../../cocos2d-x-3.0-oh/external/lua/lua")
    $text = $text.Replace("GCC_PRECOMPILE_PREFIX_HEADER = YES;", "GCC_PRECOMPILE_PREFIX_HEADER = NO;")
    $text = [regex]::Replace($text, '(?m)^\s*GCC_PREFIX_HEADER = [^;]+;\r?\n', '')

    $removedSources = @(
        "CEGUIEditboxStringParser.cpp",
        "CEGUILJXMLParser.cpp",
        "CEGUILJXMLParserHelper.cpp",
        "CEGUILJXMLParserModule.cpp",
        "CEGUILoadingTaskManager.cpp",
        "CEGUIPanelChengJiuItem.cpp",
        "CEGUIPanelChengWeiItem.cpp",
        "CEGUIPanelItem.cpp",
        "CEGUIPanelQiYuanItem.cpp",
        "CEGUIPushButtonProperties.cpp",
        "CEGUIResLoadThread.cpp",
        "CEGUISpecialTree.cpp",
        "CEGUISpecialTreeItem_xmlHandler.cpp",
        "CEGUISpecialTreeItem.cpp",
        "CEGUISILLYImageCodec.cpp",
        "CEGUISILLYImageCodecModule.cpp",
        "ETCHeader.cpp",
        "FalCompnenttip.cpp",
        "FalLinkText.cpp",
        "FalSpecialTree.cpp"
    )
    $text = Remove-PbxSourceItems -Text $text -Names $removedSources

    $baseSources = @(
        @{ Name = "CEGUIGeometryBuffer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/CEGUIGeometryBuffer.cpp" },
        @{ Name = "CEGUIMinizipResourceProvider.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/CEGUIMinizipResourceProvider.cpp" },
        @{ Name = "CEGUIRenderEffectManager.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/CEGUIRenderEffectManager.cpp" },
        @{ Name = "minibidi.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/minibidi.cpp" },
        @{ Name = "CEGUIGridLayoutContainer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUIGridLayoutContainer.cpp" },
        @{ Name = "CEGUIGridLayoutContainerProperties.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUIGridLayoutContainerProperties.cpp" },
        @{ Name = "CEGUIHorizontalLayoutContainer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUIHorizontalLayoutContainer.cpp" },
        @{ Name = "CEGUILayoutContainer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUILayoutContainer.cpp" },
        @{ Name = "CEGUIMenuItemProperties.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUIMenuItemProperties.cpp" },
        @{ Name = "CEGUISequentialLayoutContainer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUISequentialLayoutContainer.cpp" },
        @{ Name = "CEGUIVerticalLayoutContainer.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/elements/CEGUIVerticalLayoutContainer.cpp" },
        @{ Name = "ioapi.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/minizip/ioapi.cpp" },
        @{ Name = "unzip.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/minizip/unzip.cpp" }
    )
    $imageSources = @(
        @{ Name = "CEGUISTBImageCodec.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/ImageCodecModules/STBImageCodec/CEGUISTBImageCodec.cpp" },
        @{ Name = "CEGUISTBImageCodecModule.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/ImageCodecModules/STBImageCodec/CEGUISTBImageCodecModule.cpp" },
        @{ Name = "stb_image.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/ImageCodecModules/STBImageCodec/stb_image.cpp" }
    )
    $xmlSources = @(
        @{ Name = "CEGUIRapidXMLParser.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/XMLParserModules/RapidXMLParser/CEGUIRapidXMLParser.cpp" },
        @{ Name = "CEGUIRapidXMLParserModule.cpp"; Path = "../../tools/CEGUI-0.7.9-r5/cegui/src/XMLParserModules/RapidXMLParser/CEGUIRapidXMLParserModule.cpp" }
    )

    $text = Add-PbxSources -Text $text -PhaseId "4AEC046315EBA26C00E36EEB" -Sources $baseSources -Scope "cegui-base-upgrade30"
    $text = Add-PbxSources -Text $text -PhaseId "4AEC048515EBA33C00E36EEB" -Sources $imageSources -Scope "cegui-image-upgrade30"
    $text = Add-PbxSources -Text $text -PhaseId "4AEC049415EBA35700E36EEB" -Sources $xmlSources -Scope "cegui-xml-upgrade30"
    $text = Add-Upgrade30Definitions $text

    if ($text -match 'cocos2d-x-2\.2\.6|dependencies/cegui/CEGUI') {
        throw "CEGUI Upgrade30 project still contains legacy engine inputs."
    }

    Write-Utf8NoBomCrlf -Path $target -Text $text
}

function Copy-FmodCompatibilityInputs {
    param([string]$Root)

    $sourceRoot = Join-Path $Root "cocos2d-x-2.2.6"
    $targetRoot = Join-Path $Root "client/ios/vendor/fmod"
    $pairs = @(
        @{ Source = "CocosDenshion/ios/FmodAudioPlayer.cpp"; Target = "CocosDenshion/ios/FmodAudioPlayer.cpp" },
        @{ Source = "CocosDenshion/ios/FmodAudioPlayer.h"; Target = "CocosDenshion/ios/FmodAudioPlayer.h" },
        @{ Source = "CocosDenshion/ios/SimpleAudioEngineFMOD.cpp"; Target = "CocosDenshion/ios/SimpleAudioEngineFMOD.cpp" },
        @{ Source = "external/fmod/ios/lib/libfmodex_iphoneos.a"; Target = "lib/libfmodex_iphoneos.a" }
    )

    Get-ChildItem -LiteralPath (Join-Path $sourceRoot "external/fmod/ios/inc") -File | ForEach-Object {
        $pairs += @{ Source = "external/fmod/ios/inc/$($_.Name)"; Target = "inc/$($_.Name)" }
    }

    foreach ($pair in $pairs) {
        $source = Join-Path $sourceRoot $pair.Source
        $target = Join-Path $targetRoot $pair.Target
        $parent = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
            New-Item -ItemType Directory -Path $parent | Out-Null
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
    }

    $implementation = Join-Path $targetRoot "CocosDenshion/ios/SimpleAudioEngineFMOD.cpp"
    $text = Read-Utf8Text $implementation
    $text = $text.Replace(
        "unsigned int SimpleAudioEngine::playEffect(const char* pszFilePath, bool bLoop) {",
        "unsigned int SimpleAudioEngine::playEffect(const char* pszFilePath, bool bLoop, float pitch, float pan, float gain) {")
    $text = [regex]::Replace(
        $text,
        '(?s)\r?\nunsigned int SimpleAudioEngine::playEffectWithTimes\(.*?\r?\n\}\r?\n',
        "`r`n")
    Write-Utf8NoBomCrlf -Path $implementation -Text $text
}

$root = Resolve-MT3RepoRoot -RequestedRoot $RepoRoot
New-FireClientUpgrade30Project -Root $root
New-EngineUpgrade30Project -Root $root
New-CeguiUpgrade30Project -Root $root
Copy-FmodCompatibilityInputs -Root $root

Write-Host "iOS Upgrade30 projects generated:" -ForegroundColor Green
Write-Host "  client/FireClient/FireClient-Upgrade30.xcodeproj"
Write-Host "  engine/engine-Upgrade30.xcodeproj"
Write-Host "  client/ios/CEGUI-0.7.9-r5.xcodeproj"
Write-Host "  client/ios/vendor/fmod"
