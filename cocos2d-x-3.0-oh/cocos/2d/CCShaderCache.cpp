/****************************************************************************
Copyright (c) 2011      Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "CCShaderCache.h"
#include "CCGLProgram.h"
#include "ccMacros.h"
#include "ccShaders.h"

NS_CC_BEGIN

enum {
    kShaderType_PositionTextureColor,
    kShaderType_PositionTextureColor_noMVP,
    kShaderType_PositionTextureColorAlphaTest,
    kShaderType_PositionTextureColorAlphaTestNoMV,
    kShaderType_PositionColor,
    kShaderType_PositionColor_noMVP,
    kShaderType_PositionTexture,
    kShaderType_PositionTexture_uColor,
    kShaderType_PositionTextureA8Color,
    kShaderType_Position_uColor,
    kShaderType_PositionLengthTexureColor,
    // MT3 custom shader types (ported from Cocos2d-x 2.2.6)
    kShaderType_PositionTextureColorHSV,
    kShaderType_PositionTextureColorEtc,
    kShaderType_PositionTextureColorX,
    kShaderType_PositionTextureColorXEtc,
    kShaderType_PositionTextureColorGray,
    kShaderType_ControlSwitch,
    kShaderType_LabelDistanceFieldNormal,
    kShaderType_LabelDistanceFieldGlow,
    kShaderType_LabelNormal,
    kShaderType_LabelOutline,
    kShaderType_MAX,
};

static ShaderCache *_sharedShaderCache = 0;

ShaderCache* ShaderCache::getInstance()
{
    if (!_sharedShaderCache) {
        _sharedShaderCache = new ShaderCache();
        if (!_sharedShaderCache->init())
        {
            CC_SAFE_DELETE(_sharedShaderCache);
        }
    }
    return _sharedShaderCache;
}

void ShaderCache::destroyInstance()
{
    CC_SAFE_RELEASE_NULL(_sharedShaderCache);
}

// XXX: deprecated
ShaderCache* ShaderCache::sharedShaderCache()
{
    return ShaderCache::getInstance();
}

// XXX: deprecated
void ShaderCache::purgeSharedShaderCache()
{
    ShaderCache::destroyInstance();
}

ShaderCache::ShaderCache()
: _programs()
{

}

ShaderCache::~ShaderCache()
{
    for( auto it = _programs.begin(); it != _programs.end(); ++it ) {
        (it->second)->release();
    }

    CCLOGINFO("deallocing ShaderCache: %p", this);
}

bool ShaderCache::init()
{    
    loadDefaultShaders();
    return true;
}

void ShaderCache::loadDefaultShaders()
{
    // Position Texture Color shader
    GLProgram *p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColor);
    _programs.insert( std::make_pair( GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR, p ) );

    // Position Texture Color without MVP shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColor_noMVP);
    _programs.insert( std::make_pair( GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP, p ) );

    // Position Texture Color alpha test
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorAlphaTest);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_TEXTURE_ALPHA_TEST, p) );

    // Position Texture Color alpha test
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorAlphaTestNoMV);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_TEXTURE_ALPHA_TEST_NO_MV, p) );
    //
    // Position, Color shader
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionColor);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_COLOR, p) );

    //
    // Position, Color shader no MVP
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionColor_noMVP);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_COLOR_NO_MVP, p) );

    //
    // Position Texture shader
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTexture);
    _programs.insert( std::make_pair( GLProgram::SHADER_NAME_POSITION_TEXTURE, p) );

    //
    // Position, Texture attribs, 1 Color as uniform shader
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTexture_uColor);
    _programs.insert( std::make_pair( GLProgram::SHADER_NAME_POSITION_TEXTURE_U_COLOR, p) );

    //
    // Position Texture A8 Color shader
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureA8Color);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_TEXTURE_A8_COLOR, p) );

    //
    // Position and 1 color passed as a uniform (to simulate glColor4ub )
    //
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_Position_uColor);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_U_COLOR, p) );
    
    //
	// Position, Legth(TexCoords, Color (used by Draw Node basically )
	//
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionLengthTexureColor);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_POSITION_LENGTH_TEXTURE_COLOR, p) );

    p = new GLProgram();
    loadDefaultShader(p, kShaderType_LabelDistanceFieldNormal);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_LABEL_DISTANCEFIELD_NORMAL, p) );

    p = new GLProgram();
    loadDefaultShader(p, kShaderType_LabelDistanceFieldGlow);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_LABEL_DISTANCEFIELD_GLOW, p) );

    p = new GLProgram();
    loadDefaultShader(p, kShaderType_LabelNormal);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_LABEL_NORMAL, p) );

    p = new GLProgram();
    loadDefaultShader(p, kShaderType_LabelOutline);
    _programs.insert( std::make_pair(GLProgram::SHADER_NAME_LABEL_OUTLINE, p) );

    // MT3 custom shaders (ported from Cocos2d-x 2.2.6)
    // Position Texture Color HSV shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorHSV);
    _programs.insert( std::make_pair(kCCShader_PositionTextureColorHSV, p) );

    // Position Texture Color ETC shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorEtc);
    _programs.insert( std::make_pair(kCCShader_PositionTextureColorEtc, p) );

    // Position Texture Color X shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorX);
    _programs.insert( std::make_pair(kCCShader_PositionTextureColorX, p) );

    // Position Texture Color X ETC shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorXEtc);
    _programs.insert( std::make_pair(kCCShader_PositionTextureColorXEtc, p) );

    // Position Texture Color Gray shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_PositionTextureColorGray);
    _programs.insert( std::make_pair(kCCShader_PositionTextureColorGray, p) );

    // ControlSwitch shader
    p = new GLProgram();
    loadDefaultShader(p, kShaderType_ControlSwitch);
    _programs.insert( std::make_pair(kCCShader_ControlSwitch, p) );
}

void ShaderCache::reloadDefaultShaders()
{
    // reset all programs and reload them
    
    // Position Texture Color shader
    GLProgram *p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR);    
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColor);

    // Position Texture Color without MVP shader
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP);
    p->reset();    
    loadDefaultShader(p, kShaderType_PositionTextureColor_noMVP);

    // Position Texture Color alpha test
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_ALPHA_TEST);
    p->reset();    
    loadDefaultShader(p, kShaderType_PositionTextureColorAlphaTest);
    
    // Position Texture Color alpha test
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_ALPHA_TEST_NO_MV);
    p->reset();    
    loadDefaultShader(p, kShaderType_PositionTextureColorAlphaTestNoMV);
    //
    // Position, Color shader
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_COLOR);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionColor);
    
    //
    // Position, Color shader no MVP
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_COLOR_NO_MVP);
    loadDefaultShader(p, kShaderType_PositionColor_noMVP);

    //
    // Position Texture shader
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTexture);
    
    //
    // Position, Texture attribs, 1 Color as uniform shader
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_U_COLOR);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTexture_uColor);
    
    //
    // Position Texture A8 Color shader
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_A8_COLOR);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureA8Color);
    
    //
    // Position and 1 color passed as a uniform (to simulate glColor4ub )
    //
    p = getProgram(GLProgram::SHADER_NAME_POSITION_U_COLOR);
    p->reset();
    loadDefaultShader(p, kShaderType_Position_uColor);
    
    //
	// Position, Legth(TexCoords, Color (used by Draw Node basically )
	//
    p = getProgram(GLProgram::SHADER_NAME_POSITION_LENGTH_TEXTURE_COLOR);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionLengthTexureColor);

    p = getProgram(GLProgram::SHADER_NAME_LABEL_DISTANCEFIELD_NORMAL);
    p->reset();
    loadDefaultShader(p, kShaderType_LabelDistanceFieldNormal);

    p = getProgram(GLProgram::SHADER_NAME_LABEL_DISTANCEFIELD_GLOW);
    p->reset();
    loadDefaultShader(p, kShaderType_LabelDistanceFieldGlow);

    p = getProgram(GLProgram::SHADER_NAME_LABEL_NORMAL);
    p->reset();
    loadDefaultShader(p, kShaderType_LabelNormal);

    p = getProgram(GLProgram::SHADER_NAME_LABEL_OUTLINE);
    p->reset();
    loadDefaultShader(p, kShaderType_LabelOutline);

    // MT3 custom shaders reload (ported from Cocos2d-x 2.2.6)
    p = getProgram(kCCShader_PositionTextureColorHSV);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColorHSV);

    p = getProgram(kCCShader_PositionTextureColorEtc);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColorEtc);

    p = getProgram(kCCShader_PositionTextureColorX);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColorX);

    p = getProgram(kCCShader_PositionTextureColorXEtc);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColorXEtc);

    p = getProgram(kCCShader_PositionTextureColorGray);
    p->reset();
    loadDefaultShader(p, kShaderType_PositionTextureColorGray);

    p = getProgram(kCCShader_ControlSwitch);
    p->reset();
    loadDefaultShader(p, kShaderType_ControlSwitch);
}

void ShaderCache::loadDefaultShader(GLProgram *p, int type)
{
    switch (type) {
        case kShaderType_PositionTextureColor:
            p->initWithByteArrays(ccPositionTextureColor_vert, ccPositionTextureColor_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);
            
            break;
        case kShaderType_PositionTextureColor_noMVP:
            p->initWithByteArrays(ccPositionTextureColor_noMVP_vert, ccPositionTextureColor_noMVP_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;

        case kShaderType_PositionTextureColorAlphaTest:
            p->initWithByteArrays(ccPositionTextureColor_vert, ccPositionTextureColorAlphaTest_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureColorAlphaTestNoMV:
            p->initWithByteArrays(ccPositionTextureColor_noMVP_vert, ccPositionTextureColorAlphaTest_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;

        case kShaderType_PositionColor:  
            p->initWithByteArrays(ccPositionColor_vert ,ccPositionColor_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);

            break;
        case kShaderType_PositionColor_noMVP:
            p->initWithByteArrays(ccPositionTextureColor_noMVP_vert ,ccPositionColor_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            break;
        case kShaderType_PositionTexture:
            p->initWithByteArrays(ccPositionTexture_vert ,ccPositionTexture_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTexture_uColor:
            p->initWithByteArrays(ccPositionTexture_uColor_vert, ccPositionTexture_uColor_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureA8Color:
            p->initWithByteArrays(ccPositionTextureA8Color_vert, ccPositionTextureA8Color_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_Position_uColor:
            p->initWithByteArrays(ccPosition_uColor_vert, ccPosition_uColor_frag);
            
            p->bindAttribLocation("aVertex", GLProgram::VERTEX_ATTRIB_POSITION);
            
            break;
        case kShaderType_PositionLengthTexureColor:
            p->initWithByteArrays(ccPositionColorLengthTexture_vert, ccPositionColorLengthTexture_frag);
            
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            
            break;
        case kShaderType_LabelDistanceFieldNormal:
            p->initWithByteArrays(ccLabel_vert, ccLabelDistanceFieldNormal_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_LabelDistanceFieldGlow:
            p->initWithByteArrays(ccLabel_vert, ccLabelDistanceFieldGlow_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_LabelNormal:
            p->initWithByteArrays(ccLabel_vert, ccLabelNormal_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_LabelOutline:
            p->initWithByteArrays(ccLabel_vert, ccLabelOutline_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        // MT3 custom shader loaders (ported from Cocos2d-x 2.2.6)
        case kShaderType_PositionTextureColorHSV:
            p->initWithByteArrays(ccPositionTextureColorHSV_vert, ccPositionTextureColorHSV_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureColorEtc:
            p->initWithByteArrays(ccPositionTextureColorEtc_vert, ccPositionTextureColorEtc_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureColorX:
            p->initWithByteArrays(ccPositionTextureColorX_vert, ccPositionTextureColorX_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureColorXEtc:
            p->initWithByteArrays(ccPositionTextureColorXEtc_vert, ccPositionTextureColorXEtc_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_PositionTextureColorGray:
            p->initWithByteArrays(ccPositionTextureColorGray_vert, ccPositionTextureColorGray_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        case kShaderType_ControlSwitch:
            p->initWithByteArrays(ccPositionTextureColor_vert, ccExSwitchMask_frag);

            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            p->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);

            break;
        default:
            CCLOG("cocos2d: %s:%d, error shader type", __FUNCTION__, __LINE__);
            return;
    }
    
    p->link();
    p->updateUniforms();
    
    CHECK_GL_ERROR_DEBUG();
}

GLProgram* ShaderCache::getProgram(const std::string &key)
{
    auto it = _programs.find(key);
    if( it != _programs.end() )
        return it->second;
    return nullptr;
}

void ShaderCache::addProgram(GLProgram* program, const std::string &key)
{
    program->retain();
    _programs.insert( std::make_pair( key, program) );
}

// MT3 custom shader stack operations (ported from Cocos2d-x 2.2.6)
void ShaderCache::pushShader(std::string key)
{
    _shaderStack.push_back(key);

    GLProgram* pProgram = getProgram(key);
    CCAssert(pProgram, "shader program not found");
    if (pProgram && _currentShader != key)
    {
        pProgram->use();
        _currentShader = key;
    }
    if (pProgram)
    {
        pProgram->updateUniforms();
    }
}

void ShaderCache::popShader()
{
    CCAssert(!_shaderStack.empty(), "shader stack is empty");
    if (_shaderStack.empty())
    {
        _currentShader = "";
        return;
    }

    _shaderStack.pop_back();
    if (!_shaderStack.empty())
    {
        std::string key = _shaderStack.back();
        GLProgram* pProgram = getProgram(key);
        CCAssert(pProgram, "shader program not found");
        if (pProgram && _currentShader != key)
        {
            pProgram->use();
            _currentShader = key;
        }
        if (pProgram)
        {
            pProgram->updateUniforms();
        }
    }
    else
    {
        _currentShader = "";
    }
}

NS_CC_END
