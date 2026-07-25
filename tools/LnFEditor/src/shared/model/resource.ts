/** Imageset 子图像定义 */
export interface SubImageDef {
  name: string;
  xPos: number;
  yPos: number;
  width: number;
  height: number;
}

/** Imageset 资源 */
export interface ImagesetResource {
  name: string;
  textureFileName: string;
  textureFilePath: string;
  nativeHorzRes: number;
  nativeVertRes: number;
  autoScaled: boolean;
  subImages: Map<string, SubImageDef>;
}

/** Scheme 资源 */
export interface SchemeResource {
  name: string;
  imagesetFiles: string[];
  fontFiles: string[];
  lookNFeelFile: string;
  windowSetFiles: string[];
}

/** 纹理缓存条目 */
export interface TextureCacheEntry {
  imagesetName: string;
  atlasCanvas: HTMLCanvasElement | OffscreenCanvas | null;
  subImageCanvases: Map<string, HTMLCanvasElement | OffscreenCanvas>;
  lastAccessTime: number;
}

/** 资源注册表 — 管理所有已加载的 CEGUI 资源 */
export interface ResourceRegistry {
  imagesets: Map<string, ImagesetResource>;
  schemes: Map<string, SchemeResource>;
  textureCache: Map<string, TextureCacheEntry>;
  resourceRootPath: string;
}
