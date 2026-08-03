/***********************************************************************
    filename:   CEGUIScheme.cpp
    created:    21/2/2004
    author:     Paul D Turner

    purpose:    Implements GUI Scheme class
*************************************************************************/
/***************************************************************************
 *   Copyright (C) 2004 - 2006 Paul D Turner & The CEGUI Development Team
 *
 *   Permission is hereby granted, free of charge, to any person obtaining
 *   a copy of this software and associated documentation files (the
 *   "Software"), to deal in the Software without restriction, including
 *   without limitation the rights to use, copy, modify, merge, publish,
 *   distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to
 *   the following conditions:
 *
 *   The above copyright notice and this permission notice shall be
 *   included in all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 *   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *   OTHER DEALINGS IN THE SOFTWARE.
 ***************************************************************************/
#include "CEGUIScheme.h"
#include "CEGUIExceptions.h"
#include "CEGUISchemeManager.h"
#include "CEGUILogger.h"
#include "CEGUIImagesetManager.h"
#include "CEGUIImageset.h"
#include "CEGUIFontManager.h"
#include "CEGUIFont.h"
#include "CEGUIWindowFactoryManager.h"
#include "CEGUIWindowRendererManager.h"
#include "CEGUIFactoryModule.h"
#include "CEGUIScheme_xmlHandler.h"
#include "CEGUIDataContainer.h"
#include "CEGUISystem.h"
#include "CEGUIXMLParser.h"
#include "falagard/CEGUIFalWidgetLookManager.h"
#include "CEGUIWindowRendererModule.h"

#ifdef HAVE_CONFIG_H
#   include "config.h"
#endif

// Declare a function to return a WindowRendererModule as extern when
// statically linking.
#if defined(CEGUI_STATIC)
extern "C"
{
CEGUI::WindowRendererModule& getWindowRendererModule();
}
#endif


// Start of CEGUI namespace section
namespace CEGUI
{

/*************************************************************************
    Static Data definitions
*************************************************************************/
// default resource group
String Scheme::d_defaultResourceGroup;


/*************************************************************************
    Constructor for scheme objects
*************************************************************************/
Scheme::Scheme(const String& name) :
    d_name(name),
    d_incrementalLoadStage(ILS_NOT_STARTED),
    d_incrementalIndex(0),
    d_incrementalCompleted(0),
    d_incrementalTotal(0)
{
}


/*************************************************************************
    Destructor for scheme objects
*************************************************************************/
Scheme::~Scheme(void)
{
    unloadResources();

    char addr_buff[32];
    sprintf(addr_buff, "(%p)", static_cast<void*>(this));
    Logger::getSingleton().logEvent("GUI scheme '" + d_name + "' has been "
        "unloaded (object destructor). " + addr_buff, Informative);
}


/*************************************************************************
    Load all resources for this scheme
*************************************************************************/
void Scheme::loadResources(void)
{
    beginIncrementalLoad();
    while (!loadNextResource())
    {
    }
}


/*************************************************************************
    Prepare incremental resource loading
*************************************************************************/
void Scheme::beginIncrementalLoad()
{
    d_incrementalLoadStage = ILS_XML_IMAGESETS;
    d_incrementalIndex = 0;
    d_incrementalCompleted = 0;
    d_incrementalTotal = d_imagesets.size() + d_imagesetsFromImages.size() +
        d_fonts.size() + d_looknfeels.size() + d_windowRendererModules.size() +
        d_widgetModules.size() + d_aliasMappings.size() +
        d_falagardMappings.size();

    Logger::getSingleton().logEvent("---- Begining incremental resource loading for GUI scheme '" + d_name + "' ----", Informative);
}


/*************************************************************************
    Return the current incremental loading stage name
*************************************************************************/
const char* Scheme::getIncrementalLoadStageName() const
{
    switch (d_incrementalLoadStage)
    {
    case ILS_NOT_STARTED: return "not-started";
    case ILS_XML_IMAGESETS: return "imageset";
    case ILS_IMAGE_FILE_IMAGESETS: return "image-file-imageset";
    case ILS_FONTS: return "font";
    case ILS_LOOKNFEELS: return "looknfeel";
    case ILS_WINDOW_RENDERER_FACTORIES: return "window-renderer";
    case ILS_WINDOW_FACTORIES: return "window-factory";
    case ILS_FACTORY_ALIASES: return "factory-alias";
    case ILS_FALAGARD_MAPPINGS: return "falagard-mapping";
    case ILS_COMPLETE: return "complete";
    }

    return "unknown";
}


/*************************************************************************
    Load at most one declared resource
*************************************************************************/
bool Scheme::loadNextResource()
{
    if (d_incrementalLoadStage == ILS_NOT_STARTED)
        beginIncrementalLoad();

    for (;;)
    {
        switch (d_incrementalLoadStage)
        {
        case ILS_XML_IMAGESETS:
            if (d_incrementalIndex < d_imagesets.size())
            {
                LoadableUIElement& element = d_imagesets[d_incrementalIndex];
                ImagesetManager& manager = ImagesetManager::getSingleton();
                if (element.name.empty() || !manager.isDefined(element.name))
                {
                    Imageset& imageset = manager.create(element.filename, element.resourceGroup);
                    const String realname(imageset.getName());
                    if (element.name.empty())
                        element.name = realname;
                    else if (realname != element.name)
                    {
                        manager.destroy(imageset);
                        CEGUI_THROW(InvalidRequestException("Scheme::loadNextResource: The Imageset created by file '" +
                            element.filename + "' is named '" + realname + "', not '" + element.name +
                            "' as required by Scheme '" + d_name + "'."));
                    }
                }
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_IMAGE_FILE_IMAGESETS;
            d_incrementalIndex = 0;
            continue;

        case ILS_IMAGE_FILE_IMAGESETS:
            if (d_incrementalIndex < d_imagesetsFromImages.size())
            {
                LoadableUIElement& element = d_imagesetsFromImages[d_incrementalIndex];
                ImagesetManager& manager = ImagesetManager::getSingleton();
                if (element.name.empty())
                    element.name = element.filename;
                if (!manager.isDefined(element.name))
                    manager.createFromImageFile(element.name, element.filename, element.resourceGroup);
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_FONTS;
            d_incrementalIndex = 0;
            continue;

        case ILS_FONTS:
            if (d_incrementalIndex < d_fonts.size())
            {
                LoadableUIElement& element = d_fonts[d_incrementalIndex];
                FontManager& manager = FontManager::getSingleton();
                if (element.name.empty() || !manager.isDefined(element.name))
                {
                    Font& font = manager.create(element.filename, element.resourceGroup);
                    const String realname(font.getName());
                    if (element.name.empty())
                        element.name = realname;
                    else if (realname != element.name)
                    {
                        manager.destroy(font);
                        CEGUI_THROW(InvalidRequestException("Scheme::loadNextResource: The Font created by file '" +
                            element.filename + "' is named '" + realname + "', not '" + element.name +
                            "' as required by Scheme '" + d_name + "'."));
                    }
                }
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_LOOKNFEELS;
            d_incrementalIndex = 0;
            continue;

        case ILS_LOOKNFEELS:
            if (d_incrementalIndex < d_looknfeels.size())
            {
                const LoadableUIElement& element = d_looknfeels[d_incrementalIndex];
                WidgetLookManager::getSingleton().parseLookNFeelSpecification(
                    element.filename, element.resourceGroup);
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_WINDOW_RENDERER_FACTORIES;
            d_incrementalIndex = 0;
            continue;

        case ILS_WINDOW_RENDERER_FACTORIES:
            if (d_incrementalIndex < d_windowRendererModules.size())
            {
                WRModule& module = d_windowRendererModules[d_incrementalIndex];
                if (!module.wrModule)
                {
#if !defined(CEGUI_STATIC)
                    if (!module.dynamicModule)
                        module.dynamicModule = new DynamicModule(module.name);
                    WindowRendererModule& (*getWRModuleFunc)() =
                        reinterpret_cast<WindowRendererModule&(*)()>(
                            module.dynamicModule->getSymbolAddress("getWindowRendererModule"));
                    if (!getWRModuleFunc)
                        CEGUI_THROW(InvalidRequestException(
                            "Scheme::loadNextResource: Window renderer module entry point was not found in module '" +
                            module.name + "'."));
                    module.wrModule = &getWRModuleFunc();
#else
                    module.wrModule = &getWindowRendererModule();
#endif
                }

                if (module.wrTypes.empty())
                    module.wrModule->registerAllFactories();
                else
                {
                    std::vector<String>::const_iterator type = module.wrTypes.begin();
                    for (; type != module.wrTypes.end(); ++type)
                        module.wrModule->registerFactory(*type);
                }
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_WINDOW_FACTORIES;
            d_incrementalIndex = 0;
            continue;

        case ILS_WINDOW_FACTORIES:
            if (d_incrementalIndex < d_widgetModules.size())
            {
                UIModule& module = d_widgetModules[d_incrementalIndex];
                WindowFactoryManager& manager = WindowFactoryManager::getSingleton();
                if (!module.module)
                    module.module = new FactoryModule(module.name);
                if (module.factories.empty())
                    module.module->registerAllFactories();
                else
                {
                    std::vector<UIElementFactory>::const_iterator factory = module.factories.begin();
                    for (; factory != module.factories.end(); ++factory)
                    {
                        if (!manager.isFactoryPresent(factory->name))
                            module.module->registerFactory(factory->name);
                    }
                }
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_FACTORY_ALIASES;
            d_incrementalIndex = 0;
            continue;

        case ILS_FACTORY_ALIASES:
            if (d_incrementalIndex < d_aliasMappings.size())
            {
                const AliasMapping& mapping = d_aliasMappings[d_incrementalIndex];
                WindowFactoryManager& manager = WindowFactoryManager::getSingleton();
                WindowFactoryManager::TypeAliasIterator iter = manager.getAliasIterator();
                while (!iter.isAtEnd() && iter.getCurrentKey() != mapping.aliasName)
                    ++iter;
                if (iter.isAtEnd() || iter.getCurrentValue().getActiveTarget() != mapping.targetName)
                    manager.addWindowTypeAlias(mapping.aliasName, mapping.targetName);
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_FALAGARD_MAPPINGS;
            d_incrementalIndex = 0;
            continue;

        case ILS_FALAGARD_MAPPINGS:
            if (d_incrementalIndex < d_falagardMappings.size())
            {
                const FalagardMapping& mapping = d_falagardMappings[d_incrementalIndex];
                WindowFactoryManager& manager = WindowFactoryManager::getSingleton();
                WindowFactoryManager::FalagardMappingIterator iter = manager.getFalagardMappingIterator();
                while (!iter.isAtEnd() && iter.getCurrentKey() != mapping.windowName)
                    ++iter;
                if (iter.isAtEnd() ||
                    iter.getCurrentValue().d_baseType != mapping.targetName ||
                    iter.getCurrentValue().d_rendererType != mapping.rendererName ||
                    iter.getCurrentValue().d_lookName != mapping.lookName)
                {
                    manager.addFalagardWindowMapping(mapping.windowName, mapping.targetName,
                        mapping.lookName, mapping.rendererName, mapping.effectName);
                }
                ++d_incrementalIndex;
                ++d_incrementalCompleted;
                return false;
            }
            d_incrementalLoadStage = ILS_COMPLETE;
            d_incrementalIndex = 0;
            Logger::getSingleton().logEvent("---- Incremental resource loading for GUI scheme '" + d_name + "' completed ----", Informative);
            return true;

        case ILS_COMPLETE:
            return true;

        case ILS_NOT_STARTED:
            beginIncrementalLoad();
            continue;
        }
    }
}


/*************************************************************************
    Unload all resources for this scheme
*************************************************************************/
void Scheme::unloadResources(void)
{
    Logger::getSingleton().logEvent("---- Begining resource cleanup for GUI scheme '" + d_name + "' ----", Informative);

    // unload all resources specified for this scheme.
    unloadFonts();
    unloadXMLImagesets();
    unloadImageFileImagesets();
    unloadWindowFactories();
    unloadWindowRendererFactories();
    unloadFactoryAliases();
    unloadFalagardMappings();
    unloadLookNFeels();

    Logger::getSingleton().logEvent("---- Resource cleanup for GUI scheme '" + d_name + "' completed ----", Informative);
}


/*************************************************************************
    Check if all resources for this Scheme are loaded
*************************************************************************/
bool Scheme::resourcesLoaded(void) const
{
    // test state of all loadable resources for this scheme.
    if (areXMLImagesetsLoaded() &&
        areImageFileImagesetsLoaded() &&
        areFontsLoaded() &&
        areWindowRendererFactoriesLoaded() &&
        areWindowFactoriesLoaded() &&
        areFactoryAliasesLoaded() &&
        areFalagardMappingsLoaded())
    {
        return true;
    }

    return false;
}


/*************************************************************************
    Load all xml imagesets specified.
*************************************************************************/
void Scheme::loadXMLImagesets()
{
    ImagesetManager& ismgr = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::iterator  pos;

    // check all imagesets
    for (pos = d_imagesets.begin(); pos != d_imagesets.end(); ++pos)
    {
        // skip if the imageset already exists
        if (!(*pos).name.empty() && ismgr.isDefined((*pos).name))
            continue;

        // create imageset from specified file.
        Imageset& iset = ismgr.create((*pos).filename, (*pos).resourceGroup);
        const String realname(iset.getName());

        // if name was not in scheme, set it now and proceed to next imageset
        if ((*pos).name.empty())
        {
            (*pos).name = realname;
            continue;
        }

        // confirm the imageset loaded has same name specified in scheme
        if (realname != (*pos).name)
        {
            ismgr.destroy(iset);
            CEGUI_THROW(InvalidRequestException("Scheme::loadResources: "
                "The Imageset created by file '" + (*pos).filename +
                "' is named '" + realname + "', not '" + (*pos).name +
                "' as required by Scheme '" + d_name + "'."));
        }
    }
}

/*************************************************************************
    Load all image file based imagesets specified.
*************************************************************************/
void Scheme::loadImageFileImagesets()
{
    ImagesetManager& ismgr = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::iterator  pos;

    // check imagesets that are created directly from image files
    for (pos = d_imagesetsFromImages.begin(); pos != d_imagesetsFromImages.end(); ++pos)
    {
        // if name is empty use the name of the image file.
        if ((*pos).name.empty())
            (*pos).name = (*pos).filename;

        // see if imageset is present, and create it if not.
        if (!ismgr.isDefined((*pos).name))
            ismgr.createFromImageFile((*pos).name, (*pos).filename, (*pos).resourceGroup);
    }
}

/*************************************************************************
    Load all xml based fonts specified.
*************************************************************************/
void Scheme::loadFonts()
{
    FontManager& fntmgr = FontManager::getSingleton();
    std::vector<LoadableUIElement>::iterator  pos;

    // check fonts
    for (pos = d_fonts.begin(); pos != d_fonts.end(); ++pos)
    {
        // skip if a font with this name is already loaded
        if (!(*pos).name.empty() && fntmgr.isDefined((*pos).name))
            continue;

        // create font using specified xml file.
        Font& font = fntmgr.create((*pos).filename, (*pos).resourceGroup);
        const String realname(font.getName());

        // if name was not in scheme, set it now and proceed to next font
        if ((*pos).name.empty())
        {
            (*pos).name = realname;
            continue;
        }

        // confirm the font loaded has same name specified in scheme
        if (realname != (*pos).name)
        {
            fntmgr.destroy(font);
            CEGUI_THROW(InvalidRequestException("Scheme::loadResources: "
                "The Font created by file '" + (*pos).filename +
                "' is named '" + realname + "', not '" + (*pos).name +
                "' as required by Scheme '" + d_name + "'."));
        }
    }
}

/*************************************************************************
    Load all xml LookNFeel files specified.
*************************************************************************/
void Scheme::loadLookNFeels()
{
    WidgetLookManager& wlfMgr   = WidgetLookManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // load look'n'feels
    // (we can't actually check these, at the moment, so we just re-parse data;
    // it does no harm except maybe waste a bit of time)
    for (pos = d_looknfeels.begin(); pos != d_looknfeels.end(); ++pos)
        wlfMgr.parseLookNFeelSpecification((*pos).filename, (*pos).resourceGroup);
}

/*************************************************************************
    Load all windowset modules specified.and register factories.
*************************************************************************/
void Scheme::loadWindowFactories()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();

    // check factories
    std::vector<UIModule>::iterator cmod = d_widgetModules.begin();
    for (;cmod != d_widgetModules.end(); ++cmod)
    {
        // create and load dynamic module as required
        if (!(*cmod).module)
        {
            (*cmod).module = new FactoryModule((*cmod).name);
        }

        // see if we should just register all factories available in the module (i.e. No factories explicitly specified)
        if ((*cmod).factories.size() == 0)
        {
            Logger::getSingleton().logEvent("No window factories specified for module '" + (*cmod).name + "' - adding all available factories...");
            (*cmod).module->registerAllFactories();
        }
        // some names were explicitly given, so only register those.
        else
        {
            std::vector<UIElementFactory>::const_iterator   elem = (*cmod).factories.begin();
            for (; elem != (*cmod).factories.end(); ++elem)
            {
                if (!wfmgr.isFactoryPresent((*elem).name))
                {
                    (*cmod).module->registerFactory((*elem).name);
                }
            }
        }
    }
}

/*************************************************************************
    Load all windowrendererset modules specified.and register factories.
*************************************************************************/
void Scheme::loadWindowRendererFactories()
{
    // check factories
    std::vector<WRModule>::iterator cmod = d_windowRendererModules.begin();
    for (;cmod != d_windowRendererModules.end(); ++cmod)
    {
        if (!(*cmod).wrModule)
        {
#if !defined(CEGUI_STATIC)
            // load dynamic module as required
            if (!(*cmod).dynamicModule)
                (*cmod).dynamicModule = new DynamicModule((*cmod).name);

            WindowRendererModule& (*getWRModuleFunc)() =
                reinterpret_cast<WindowRendererModule&(*)()>(
                    (*cmod).dynamicModule->
                        getSymbolAddress("getWindowRendererModule"));

            if (!getWRModuleFunc)
                CEGUI_THROW(InvalidRequestException(
                    "Scheme::loadWindowRendererFactories: Required function "
                    "export 'WindowRendererModule& getWindowRendererModule()' "
                    "was not found in module '" + (*cmod).name + "'."));

            // get the WindowRendererModule object for this module.
            (*cmod).wrModule = &getWRModuleFunc();
#else
            (*cmod).wrModule = &getWindowRendererModule();
#endif
        }

        // see if we should just register all factories available in the module
        // (i.e. No factories explicitly specified)
        if ((*cmod).wrTypes.size() == 0)
        {
            Logger::getSingleton().logEvent("No window renderer factories "
                                            "specified for module '" +
                                            (*cmod).name + "' - adding all "
                                            "available factories...");
            (*cmod).wrModule->registerAllFactories();
        }
        // some names were explicitly given, so only register those.
        else
        {
            std::vector<String>::const_iterator elem = (*cmod).wrTypes.begin();
            for (; elem != (*cmod).wrTypes.end(); ++elem)
                (*cmod).wrModule->registerFactory(*elem);
        }
    }
}

/*************************************************************************
    Create all window factory aliases
*************************************************************************/
void Scheme::loadFactoryAliases()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();

    // check aliases
    std::vector<AliasMapping>::iterator alias = d_aliasMappings.begin();
    for (;alias != d_aliasMappings.end(); ++alias)
    {
        // get iterator
        WindowFactoryManager::TypeAliasIterator iter = wfmgr.getAliasIterator();

        // look for this alias
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*alias).aliasName))
            ++iter;

        // if the alias exists
        if (!iter.isAtEnd())
        {
            // if the current target type matches
            if (iter.getCurrentValue().getActiveTarget() == (*alias).targetName)
            {
                // assume this mapping is ours and skip to next alias
                continue;
            }
        }

        // create a new alias entry
        wfmgr.addWindowTypeAlias((*alias).aliasName, (*alias).targetName);
    }
}

/*************************************************************************
    Create all required falagard mappings
*************************************************************************/
void Scheme::loadFalagardMappings()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();

    // check falagard window mappings.
    std::vector<FalagardMapping>::iterator falagard = d_falagardMappings.begin();
    for (;falagard != d_falagardMappings.end(); ++falagard)
    {
        // get iterator
        WindowFactoryManager::FalagardMappingIterator iter = wfmgr.getFalagardMappingIterator();

        // look for this mapping
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*falagard).windowName))
            ++iter;

        // if the mapping exists
        if (!iter.isAtEnd())
        {
            // check if the current target and looks and window renderer match
            if ((iter.getCurrentValue().d_baseType == (*falagard).targetName) &&
                (iter.getCurrentValue().d_rendererType == (*falagard).rendererName) &&
                (iter.getCurrentValue().d_lookName == (*falagard).lookName))
            {
                // assume this mapping is ours and skip to next
                continue;
            }
        }

        // create a new mapping entry
        wfmgr.addFalagardWindowMapping((*falagard).windowName,
                                       (*falagard).targetName,
                                       (*falagard).lookName,
                                       (*falagard).rendererName,
                                       (*falagard).effectName);
    }
}

/*************************************************************************
    Unload all xml based imagesets
*************************************************************************/
void Scheme::unloadXMLImagesets()
{
    ImagesetManager& ismgr      = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // unload all xml based Imagesets
    for (pos = d_imagesets.begin(); pos != d_imagesets.end(); ++pos)
        if (!(*pos).name.empty())
            ismgr.destroy((*pos).name);
}

/*************************************************************************
    Unload all image file based imagesets
*************************************************************************/
void Scheme::unloadImageFileImagesets()
{
    ImagesetManager& ismgr      = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // unload all imagesets that are created directly from image files
    for (pos = d_imagesetsFromImages.begin(); pos != d_imagesetsFromImages.end(); ++pos)
        if (!(*pos).name.empty())
            ismgr.destroy((*pos).name);
}

/*************************************************************************
    Unload all xml based fonts
*************************************************************************/
void Scheme::unloadFonts()
{
    FontManager& fntmgr         = FontManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // unload all loaded fonts
    for (pos = d_fonts.begin(); pos != d_fonts.end(); ++pos)
        if (!(*pos).name.empty())
            fntmgr.destroy((*pos).name);
}

/*************************************************************************
    Unload all xml based LookNfeels
*************************************************************************/
void Scheme::unloadLookNFeels()
{
    // While it's possible to remove WidgetLooks etc, currently we can't
    // extract which looks were loaded from a given xml file, so we just
    // do nothing for now.
}

/*************************************************************************
    Unregister all window factories and unload shared modules
*************************************************************************/
void Scheme::unloadWindowFactories()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<UIModule>::iterator cmod = d_widgetModules.begin();

    // for all widget modules loaded
    for (;cmod != d_widgetModules.end(); ++cmod)
    {
        // see if we should just unregister all factories available in the
        // module (i.e. No factories explicitly specified)
        if ((*cmod).factories.size() == 0)
        {
            // TODO: This is not supported yet!
        }
        // remove all window factories explicitly registered for this module
        else
        {
            std::vector<UIElementFactory>::const_iterator elem = (*cmod).factories.begin();
            for (; elem != (*cmod).factories.end(); ++elem)
                wfmgr.removeFactory((*elem).name);
        }

        // unload dynamic module as required
        if ((*cmod).module)
        {
            delete (*cmod).module;
            (*cmod).module = 0;
        }
    }
}

/*************************************************************************
    Unregister all window renderer factories and unload shared modules
*************************************************************************/
void Scheme::unloadWindowRendererFactories()
{
    std::vector<WRModule>::iterator cmod = d_windowRendererModules.begin();

    // for all widget modules loaded
    for (;cmod != d_windowRendererModules.end(); ++cmod)
    {
        // assume module's factories were already removed if wrModule is 0.
        if (!(*cmod).wrModule)
            continue;

        // see if we should just unregister all factories available in the
        // module (i.e. No factories explicitly specified)
        if ((*cmod).wrTypes.size() == 0)
        {
            (*cmod).wrModule->unregisterAllFactories();
        }
        // remove all window factories explicitly registered for this module
        else
        {
            std::vector<String>::const_iterator elem = (*cmod).wrTypes.begin();
            for (; elem != (*cmod).wrTypes.end(); ++elem)
                (*cmod).wrModule->unregisterFactory(*elem);
        }

        // unload dynamic module as required
        if ((*cmod).dynamicModule)
        {
            delete (*cmod).dynamicModule;
            (*cmod).dynamicModule = 0;
        }

        (*cmod).wrModule = 0;
    }
}

/*************************************************************************
    Unregister all factory aliases
*************************************************************************/
void Scheme::unloadFactoryAliases()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<AliasMapping>::iterator alias = d_aliasMappings.begin();

    // remove all factory aliases
    for (;alias != d_aliasMappings.end(); ++alias)
    {
        // get iterator
        WindowFactoryManager::TypeAliasIterator iter = wfmgr.getAliasIterator();

        // look for this alias
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*alias).aliasName))
            ++iter;

        // if the alias exists
        if (!iter.isAtEnd())
            // remove this alias entry
            wfmgr.removeWindowTypeAlias((*alias).aliasName, (*alias).targetName);
    }
}

/*************************************************************************
    Unregister all Falagard window type mappings
*************************************************************************/
void Scheme::unloadFalagardMappings()
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<FalagardMapping>::iterator falagard = d_falagardMappings.begin();

    // remove all falagard window mappings for this scheme.
    for (;falagard != d_falagardMappings.end(); ++falagard)
    {
        // get iterator
        WindowFactoryManager::FalagardMappingIterator iter = wfmgr.getFalagardMappingIterator();

        // look for this mapping
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*falagard).windowName))
            ++iter;

        // if the mapping exists
        if (!iter.isAtEnd())
        {
            // if the current target and looks match
            if ((iter.getCurrentValue().d_baseType == (*falagard).targetName) &&
                (iter.getCurrentValue().d_rendererType == (*falagard).rendererName) &&
                (iter.getCurrentValue().d_lookName == (*falagard).lookName))
            {
                // assume this mapping is ours and delete it
                wfmgr.removeFalagardWindowMapping((*falagard).targetName);
            }
        }
    }
}

/*************************************************************************
    Check if all XML based imagesets are loaded
*************************************************************************/
bool Scheme::areXMLImagesetsLoaded() const
{
    ImagesetManager& ismgr = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // check imagesets
    for (pos = d_imagesets.begin(); pos != d_imagesets.end(); ++pos)
        if ((*pos).name.empty() || !ismgr.isDefined((*pos).name))
            return false;

    return true;
}

/*************************************************************************
    Check if all image file based imagesets are loaded
*************************************************************************/
bool Scheme::areImageFileImagesetsLoaded() const
{
    ImagesetManager& ismgr = ImagesetManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    for (pos = d_imagesetsFromImages.begin(); pos != d_imagesetsFromImages.end(); ++pos)
        if ((*pos).name.empty() || !ismgr.isDefined((*pos).name))
            return false;

    return true;
}

/*************************************************************************
    Check if all xml based fonts are loaded
*************************************************************************/
bool Scheme::areFontsLoaded() const
{
    FontManager& fntmgr = FontManager::getSingleton();
    std::vector<LoadableUIElement>::const_iterator  pos;

    // check fonts
    for (pos = d_fonts.begin(); pos != d_fonts.end(); ++pos)
        if ((*pos).name.empty() || !fntmgr.isDefined((*pos).name))
            return false;

    return true;
}

/*************************************************************************
    Check if xml looknfeel files are loaded
*************************************************************************/
bool Scheme::areLookNFeelsLoaded() const
{
    // can't check these at the moment, just say yes!
    return true;
}

/*************************************************************************
    Check if all required window factories are registered
*************************************************************************/
bool Scheme::areWindowFactoriesLoaded() const
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<UIModule>::const_iterator   cmod = d_widgetModules.begin();

    // check factory modules
    for (;cmod != d_widgetModules.end(); ++cmod)
    {
        // see if we should just test all factories available in the
        // module (i.e. No factories explicitly specified)
        if ((*cmod).factories.size() == 0)
        {
            // TODO: This is not supported yet!
        }
        // check all window factories explicitly registered for this module
        else
        {
            std::vector<UIElementFactory>::const_iterator   elem = (*cmod).factories.begin();

            for (; elem != (*cmod).factories.end(); ++elem)
            {
                if (!wfmgr.isFactoryPresent((*elem).name))
                    return false;
            }
        }
    }

    return true;
}

/*************************************************************************
    Check if all required window renderer factories are registered
*************************************************************************/
bool Scheme::areWindowRendererFactoriesLoaded() const
{
    WindowRendererManager& wfmgr = WindowRendererManager::getSingleton();
    std::vector<WRModule>::const_iterator cmod = d_windowRendererModules.begin();

    // check factory modules
    for (;cmod != d_windowRendererModules.end(); ++cmod)
    {
        // see if we should just test all factories available in the
        // module (i.e. No factories explicitly specified)
        if ((*cmod).wrTypes.size() == 0)
        {
            // TODO: This is not supported yet!
        }
        // check all window factories explicitly registered for this module
        else
        {
            std::vector<String>::const_iterator elem = (*cmod).wrTypes.begin();

            for (; elem != (*cmod).wrTypes.end(); ++elem)
                if (!wfmgr.isFactoryPresent(*elem))
                    return false;
        }
    }

    return true;
}

/*************************************************************************
    Check if all window factory aliases are registered
*************************************************************************/
bool Scheme::areFactoryAliasesLoaded() const
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<AliasMapping>::const_iterator alias = d_aliasMappings.begin();

    // check aliases
    for (;alias != d_aliasMappings.end(); ++alias)
    {
        // get iterator
        WindowFactoryManager::TypeAliasIterator iter = wfmgr.getAliasIterator();

        // look for this alias
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*alias).aliasName))
            ++iter;

        // if the alias exists
        if (!iter.isAtEnd())
        {
            // if the current target type matches
            if (iter.getCurrentValue().getActiveTarget() == (*alias).targetName)
                // target matches, assume we set it and continue to next alias
                continue;
        }

        // no alias or target type does not match
        return false;
    }

    return true;
}

/*************************************************************************
    Check if all falagard mappings are registered
*************************************************************************/
bool Scheme::areFalagardMappingsLoaded() const
{
    WindowFactoryManager& wfmgr = WindowFactoryManager::getSingleton();
    std::vector<FalagardMapping>::const_iterator falagard = d_falagardMappings.begin();

    // check falagard window mappings.
    for (;falagard != d_falagardMappings.end(); ++falagard)
    {
        // get iterator
        WindowFactoryManager::FalagardMappingIterator iter = wfmgr.getFalagardMappingIterator();

        // look for this mapping
        while (!iter.isAtEnd() && (iter.getCurrentKey() != (*falagard).windowName))
            ++iter;

        // if the mapping exists
        if (!iter.isAtEnd())
        {
            // if the current target, effect and looks match
            if ((iter.getCurrentValue().d_baseType == (*falagard).targetName) &&
                (iter.getCurrentValue().d_rendererType == (*falagard).rendererName) &&
                (iter.getCurrentValue().d_lookName == (*falagard).lookName) &&
                (iter.getCurrentValue().d_effectName == (*falagard).effectName))
            {
                // assume this mapping is ours and skip to next
                continue;
            }
        }

        return false;
    }

    return true;
}

} // End of  CEGUI namespace section
