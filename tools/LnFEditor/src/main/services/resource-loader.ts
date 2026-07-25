import * as fs from 'fs';
import * as path from 'path';
import { XMLParser } from 'fast-xml-parser';
import type { ImagesetResource, SubImageDef, SchemeResource } from '@shared/model';

/** 解析 .imageset 文件 */
export function parseImageset(filePath: string): ImagesetResource {
  const content = fs.readFileSync(filePath, 'utf-8');
  const parser = new XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: '@_',
    isArray: (name: string) => name === 'Image',
  });

  const parsed = parser.parse(content);
  const is = parsed.Imageset;
  if (!is) throw new Error(`Invalid imageset file: ${filePath}`);

  const dir = path.dirname(filePath);
  const textureFileName = is['@_Imagefile'] as string;
  const subImages = new Map<string, SubImageDef>();

  const images = is.Image || [];
  for (const img of images) {
    const name = img['@_Name'] as string;
    subImages.set(name, {
      name,
      xPos: parseInt(img['@_XPos'] as string, 10) || 0,
      yPos: parseInt(img['@_YPos'] as string, 10) || 0,
      width: parseInt(img['@_Width'] as string, 10) || 0,
      height: parseInt(img['@_Height'] as string, 10) || 0,
    });
  }

  return {
    name: is['@_Name'] as string,
    textureFileName,
    textureFilePath: path.resolve(dir, textureFileName),
    nativeHorzRes: parseInt(is['@_NativeHorzRes'] as string, 10) || 1024,
    nativeVertRes: parseInt(is['@_NativeVertRes'] as string, 10) || 1024,
    autoScaled: (is['@_AutoScaled'] as string) === 'true',
    subImages,
  };
}

/** 解析 .scheme 文件 */
export function parseScheme(filePath: string): SchemeResource {
  const content = fs.readFileSync(filePath, 'utf-8');
  const parser = new XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: '@_',
    isArray: (name: string) => ['Imageset', 'Font', 'WindowSet', 'WindowAlias'].includes(name),
  });

  const parsed = parser.parse(content);
  const scheme = parsed.GUIScheme;
  if (!scheme) throw new Error(`Invalid scheme file: ${filePath}`);

  const dir = path.dirname(filePath);

  const imagesetFiles: string[] = [];
  if (scheme.Imageset) {
    for (const is of scheme.Imageset) {
      const filename = is['@_Filename'] as string;
      if (filename) imagesetFiles.push(path.resolve(dir, filename));
    }
  }

  const fontFiles: string[] = [];
  if (scheme.Font) {
    for (const f of scheme.Font) {
      const filename = f['@_Filename'] as string;
      if (filename) fontFiles.push(path.resolve(dir, filename));
    }
  }

  let lookNFeelFile = '';
  if (scheme.LookNFeel) {
    const lnf = Array.isArray(scheme.LookNFeel) ? scheme.LookNFeel[0] : scheme.LookNFeel;
    const filename = lnf['@_Filename'] as string;
    if (filename) lookNFeelFile = path.resolve(dir, filename);
  }

  return {
    name: scheme['@_Name'] as string,
    imagesetFiles,
    fontFiles,
    lookNFeelFile,
    windowSetFiles: [],
  };
}

/** 批量加载 scheme 引用的所有 imageset */
export function loadImagesetsFromScheme(scheme: SchemeResource): Map<string, ImagesetResource> {
  const result = new Map<string, ImagesetResource>();
  for (const isPath of scheme.imagesetFiles) {
    try {
      const is = parseImageset(isPath);
      result.set(is.name, is);
    } catch (e) {
      console.warn(`Failed to load imageset: ${isPath}`, e);
    }
  }
  return result;
}

/** 扫描目录下所有 .imageset 文件 */
export function scanImagesetDir(dirPath: string): string[] {
  if (!fs.existsSync(dirPath)) return [];
  return fs.readdirSync(dirPath)
    .filter(f => f.endsWith('.imageset'))
    .map(f => path.resolve(dirPath, f));
}
