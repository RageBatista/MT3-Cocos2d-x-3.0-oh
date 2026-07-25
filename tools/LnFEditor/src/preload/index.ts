import { contextBridge, ipcRenderer } from 'electron';

const api = Object.freeze({
  openLookNFeel: () => ipcRenderer.invoke('open-looknfeel'),
  loadWidgetLook: (filePath: string, indexJson: string) => ipcRenderer.invoke('load-widgetlook', filePath, indexJson),
  openScheme: () => ipcRenderer.invoke('open-scheme'),
  readImageBase64: (filePath: string) => ipcRenderer.invoke('read-image-base64', filePath),
  saveLookNFeel: (filePath: string, widgetLooksJson: string) => ipcRenderer.invoke('save-looknfeel', filePath, widgetLooksJson),
  scanImagesets: (dirPath: string) => ipcRenderer.invoke('scan-imagesets', dirPath),
  loadImagesets: (filePathsJson: string) => ipcRenderer.invoke('load-imagesets', filePathsJson),
  discoverResources: (looknfeelPath: string) => ipcRenderer.invoke('discover-resources', looknfeelPath),
  syncSchemeMappings: (schemePath: string, widgetLookNamesJson: string) => ipcRenderer.invoke('sync-scheme-mappings', schemePath, widgetLookNamesJson),
  validateReferences: (widgetLooksJson: string, imagesetsJson: string) => ipcRenderer.invoke('validate-references', widgetLooksJson, imagesetsJson),
  savePng: (dataUrlJson: string, defaultName: string) => ipcRenderer.invoke('save-png', dataUrlJson, defaultName),
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  getLocale: () => ipcRenderer.invoke('get-locale'),
});

contextBridge.exposeInMainWorld('lnfAPI', api);

export type LnfAPI = typeof api;
