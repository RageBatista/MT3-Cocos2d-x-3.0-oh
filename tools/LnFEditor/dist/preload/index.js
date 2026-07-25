"use strict";
const electron = require("electron");
const api = Object.freeze({
  openLookNFeel: () => electron.ipcRenderer.invoke("open-looknfeel"),
  loadWidgetLook: (filePath, indexJson) => electron.ipcRenderer.invoke("load-widgetlook", filePath, indexJson),
  openScheme: () => electron.ipcRenderer.invoke("open-scheme"),
  readImageBase64: (filePath) => electron.ipcRenderer.invoke("read-image-base64", filePath),
  saveLookNFeel: (filePath, widgetLooksJson) => electron.ipcRenderer.invoke("save-looknfeel", filePath, widgetLooksJson),
  scanImagesets: (dirPath) => electron.ipcRenderer.invoke("scan-imagesets", dirPath),
  loadImagesets: (filePathsJson) => electron.ipcRenderer.invoke("load-imagesets", filePathsJson),
  discoverResources: (looknfeelPath) => electron.ipcRenderer.invoke("discover-resources", looknfeelPath),
  syncSchemeMappings: (schemePath, widgetLookNamesJson) => electron.ipcRenderer.invoke("sync-scheme-mappings", schemePath, widgetLookNamesJson),
  validateReferences: (widgetLooksJson, imagesetsJson) => electron.ipcRenderer.invoke("validate-references", widgetLooksJson, imagesetsJson),
  savePng: (dataUrlJson, defaultName) => electron.ipcRenderer.invoke("save-png", dataUrlJson, defaultName),
  getAppVersion: () => electron.ipcRenderer.invoke("get-app-version"),
  getLocale: () => electron.ipcRenderer.invoke("get-locale")
});
electron.contextBridge.exposeInMainWorld("lnfAPI", api);
