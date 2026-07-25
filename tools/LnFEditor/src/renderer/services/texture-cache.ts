/**
 * 纹理缓存服务 — LRU 缓存管理 CEGUI Imageset 纹理
 *
 * 职责:
 * - 加载 imageset 纹理图集（通过 IPC 从主进程获取 Base64）
 * - 裁剪子图像到独立 Canvas
 * - LRU 淘汰策略
 * - 提供 SubImageCache 接口给渲染引擎
 */

import type { SubImageDef, ImagesetResource, WidgetLook } from '@shared/model';
import type { SubImageCache } from '../canvas/renderer';
import { TEXTURE_CACHE_MAX_SIZE } from '@shared/constants';
import { resolveImagerySection } from './widgetlook-lookup';

/** 缓存条目 */
interface CacheEntry {
  canvas: HTMLCanvasElement;
  lastAccess: number;
}

/** 纹理加载请求状态 */
type LoadState = 'idle' | 'loading' | 'loaded' | 'error';

/** 纹理加载回调 */
type OnLoadComplete = () => void;

export class TextureCacheManager implements SubImageCache {
  /** 子图像缓存: `${imageset}/${image}` → Canvas */
  private cache = new Map<string, CacheEntry>();

  /** 已加载的 imageset 资源注册表 */
  private imagesets = new Map<string, ImagesetResource>();

  /** 已加载的纹理图集 HTMLImageElement */
  private atlasImages = new Map<string, HTMLImageElement>();

  /** 纹理加载状态 */
  private loadStates = new Map<string, LoadState>();

  /** 加载完成回调列表 */
  private loadCallbacks = new Map<string, OnLoadComplete[]>();

  /** 注册 imageset 资源 */
  registerImageset(resource: ImagesetResource): void {
    this.imagesets.set(resource.name, resource);
  }

  /** 批量注册 imageset 资源 */
  registerImagesets(resources: ImagesetResource[]): void {
    for (const r of resources) {
      this.imagesets.set(r.name, r);
    }
  }

  /** 请求加载纹理图集（异步） */
  async loadAtlas(imagesetName: string): Promise<void> {
    const resource = this.imagesets.get(imagesetName);
    if (!resource) {
      console.warn(`TextureCache: Unknown imageset "${imagesetName}"`);
      return;
    }

    const state = this.loadStates.get(imagesetName);
    if (state === 'loaded' || state === 'loading') return;

    this.loadStates.set(imagesetName, 'loading');

    try {
      const base64 = await window.lnfAPI.readImageBase64(resource.textureFilePath);
      if (!base64) {
        this.loadStates.set(imagesetName, 'error');
        console.warn(`TextureCache: Failed to load texture: ${resource.textureFilePath}`);
        return;
      }

      const img = new Image();
      img.src = base64;

      await new Promise<void>((resolve, reject) => {
        img.onload = () => resolve();
        img.onerror = () => reject(new Error(`Failed to decode image: ${resource.textureFilePath}`));
      });

      this.atlasImages.set(imagesetName, img);
      this.loadStates.set(imagesetName, 'loaded');

      // 预裁剪所有子图像
      this.preClipSubImages(imagesetName, resource, img);

      // 通知等待中的回调
      const callbacks = this.loadCallbacks.get(imagesetName);
      if (callbacks) {
        this.loadCallbacks.delete(imagesetName);
        for (const cb of callbacks) cb();
      }
    } catch (e) {
      this.loadStates.set(imagesetName, 'error');
      console.warn(`TextureCache: Error loading atlas "${imagesetName}":`, e);
    }
  }

  /** 预裁剪所有子图像到缓存 */
  private preClipSubImages(
    imagesetName: string,
    resource: ImagesetResource,
    atlasImg: HTMLImageElement,
  ): void {
    for (const [subName, subDef] of resource.subImages) {
      const key = `${imagesetName}/${subName}`;
      if (this.cache.has(key)) continue;

      const canvas = document.createElement('canvas');
      canvas.width = subDef.width;
      canvas.height = subDef.height;

      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.drawImage(
          atlasImg,
          subDef.xPos, subDef.yPos, subDef.width, subDef.height,
          0, 0, subDef.width, subDef.height,
        );
      }

      this.cache.set(key, { canvas, lastAccess: Date.now() });
    }

    // 检查是否需要淘汰
    this.evictIfNeeded();
  }

  /** SubImageCache 接口实现 — 获取子图像 Canvas */
  get(imageset: string, image: string): HTMLCanvasElement | OffscreenCanvas | null {
    const key = `${imageset}/${image}`;
    const entry = this.cache.get(key);
    if (entry) {
      entry.lastAccess = Date.now();
      return entry.canvas;
    }

    // 如果图集已加载但子图像未缓存，可能是新注册的
    const resource = this.imagesets.get(imageset);
    const atlasImg = this.atlasImages.get(imageset);
    if (resource && atlasImg) {
      const subDef = resource.subImages.get(image);
      if (subDef) {
        const canvas = document.createElement('canvas');
        canvas.width = subDef.width;
        canvas.height = subDef.height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.drawImage(
            atlasImg,
            subDef.xPos, subDef.yPos, subDef.width, subDef.height,
            0, 0, subDef.width, subDef.height,
          );
        }
        this.cache.set(key, { canvas, lastAccess: Date.now() });
        this.evictIfNeeded();
        return canvas;
      }
    }

    return null;
  }

  /** SubImageCache 接口实现 — 检查子图像是否存在 */
  has(imageset: string, image: string): boolean {
    return this.cache.has(`${imageset}/${image}`);
  }

  /** 获取 imageset 的加载状态 */
  getLoadState(imagesetName: string): LoadState {
    return this.loadStates.get(imagesetName) || 'idle';
  }

  /** 获取子图像尺寸信息 */
  getSubImageSize(imageset: string, image: string): { width: number; height: number } | null {
    const resource = this.imagesets.get(imageset);
    if (!resource) return null;
    const subDef = resource.subImages.get(image);
    if (!subDef) return null;
    return { width: subDef.width, height: subDef.height };
  }

  /** 获取子图像的 Data URL（用于 InspectorPanel Resources 缩略图） */
  getSubImageDataUrl(imageset: string, image: string): string | null {
    const canvas = this.get(imageset, image);
    if (!canvas) return null;
    try {
      return (canvas as HTMLCanvasElement).toDataURL('image/png');
    } catch {
      return null;
    }
  }

  /** 收集 WidgetLook 中引用的所有 imageset 名称 */
  extractRequiredImagesets(widgetLook: WidgetLook, availableLooks?: Map<string, WidgetLook>): string[] {
    const names = new Set<string>();
    const sectionMap = new Map(widgetLook.imagerySections.map(section => [section.name, section]));

    const collectFromSection = (section: WidgetLook['imagerySections'][number]): void => {
      for (const fc of section.frameComponents) {
        for (const ref of Object.values(fc.images)) {
          if (ref?.imageset) names.add(ref.imageset);
        }
      }
      for (const ic of section.imageryComponents) {
        if (ic.image?.imageset) names.add(ic.image.imageset);
      }
    };

    for (const section of widgetLook.imagerySections) {
      collectFromSection(section);
    }

    for (const state of widgetLook.stateImagerys ?? []) {
      for (const layer of state.layers) {
        for (const sectionRef of layer.sections) {
          const resolvedSection = resolveImagerySection(sectionRef, widgetLook.name, sectionMap, availableLooks);
          if (resolvedSection) {
            collectFromSection(resolvedSection);
          }
        }
      }
    }

    return Array.from(names);
  }

  /** 批量加载 WidgetLook 所需的所有纹理 */
  async loadRequiredTextures(widgetLook: WidgetLook, availableLooks?: Map<string, WidgetLook>): Promise<void> {
    const required = this.extractRequiredImagesets(widgetLook, availableLooks);
    const promises = required
      .filter(name => {
        const state = this.loadStates.get(name);
        return state !== 'loaded' && state !== 'loading';
      })
      .map(name => this.loadAtlas(name));

    await Promise.allSettled(promises);
  }

  /** LRU 淘汰 */
  private evictIfNeeded(): void {
    if (this.cache.size <= TEXTURE_CACHE_MAX_SIZE) return;

    // 按访问时间排序，淘汰最旧的
    const entries = Array.from(this.cache.entries())
      .sort((a, b) => a[1].lastAccess - b[1].lastAccess);

    const toRemove = this.cache.size - TEXTURE_CACHE_MAX_SIZE;
    for (let i = 0; i < toRemove && i < entries.length; i++) {
      this.cache.delete(entries[i][0]);
    }
  }

  /** 清除所有缓存 */
  clear(): void {
    this.cache.clear();
    this.atlasImages.clear();
    this.loadStates.clear();
    this.loadCallbacks.clear();
  }

  /** 清除指定 imageset 的缓存 */
  invalidateImageset(imagesetName: string): void {
    // 删除该 imageset 的所有子图像缓存
    for (const key of this.cache.keys()) {
      if (key.startsWith(`${imagesetName}/`)) {
        this.cache.delete(key);
      }
    }
    this.atlasImages.delete(imagesetName);
    this.loadStates.delete(imagesetName);
  }

  /** 获取缓存统计信息 */
  getStats(): { cachedCount: number; maxSize: number; loadedAtlases: number } {
    return {
      cachedCount: this.cache.size,
      maxSize: TEXTURE_CACHE_MAX_SIZE,
      loadedAtlases: this.atlasImages.size,
    };
  }
}

/** 全局单例 */
export const textureCache = new TextureCacheManager();
