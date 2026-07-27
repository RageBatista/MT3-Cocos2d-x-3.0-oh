#ifndef __VIDEOPLAYERENGINE_H_
#define __VIDEOPLAYERENGINE_H_

#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#include "cocos2d.h"
#include <string>

NS_CC_BEGIN

class VideoPlayer : public Ref
{
public:
    enum SourceType
    {
        FILENAME = 0,
        URL
    };

    enum EventType
    {
        PLAYING = 0,
        PAUSED,
        STOPPED,
        COMPLETED,
        TERMINATION,
        QUIT_FULLSCREEN = 1000,
    };

    typedef void (*VideoPlayerCallback)(VideoPlayer::EventType);

public:
    VideoPlayer()
        : _isPlaying(false)
        , _fullScreenEnabled(false)
        , _keepAspectRatioEnabled(true)
        , _videoSource(FILENAME)
        , _eventCallback(NULL)
    {
    }

    virtual ~VideoPlayer()
    {
        unscheduleCompletionCallback();
    }

    static VideoPlayer* create()
    {
        VideoPlayer* pPlayer = new VideoPlayer;
        if (pPlayer)
        {
            pPlayer->autorelease();
        }
        return pPlayer;
    }

    void setFileName(const std::string& videoPath, const std::string& /*title*/, const std::string& /*backgroundiamge*/)
    {
        _videoURL = videoPath;
        _videoSource = FILENAME;
    }

    const std::string& getFileName() const
    {
        return _videoURL;
    }

    void setURL(const std::string& videoURL, const std::string& /*title*/, const std::string& /*backgroundiamge*/)
    {
        _videoURL = videoURL;
        _videoSource = URL;
    }

    const std::string& getURL() const
    {
        return _videoURL;
    }

    void play()
    {
        _isPlaying = true;
        scheduleCompletionCallback();
    }

    void pause()
    {
        _isPlaying = false;
    }

    void resume()
    {
        play();
    }

    void stop()
    {
        _isPlaying = false;
        unscheduleCompletionCallback();
    }

    void seekTo(float /*sec*/)
    {
    }

    bool isPlaying() const
    {
        return _isPlaying;
    }

    void setKeepAspectRatioEnabled(bool enable)
    {
        _keepAspectRatioEnabled = enable;
    }

    bool isKeepAspectRatioEnabled() const
    {
        return _keepAspectRatioEnabled;
    }

    void setFullScreenEnabled(bool fullscreen)
    {
        _fullScreenEnabled = fullscreen;
    }

    bool isFullScreenEnabled() const
    {
        return _fullScreenEnabled;
    }

    void setVisible(bool /*visible*/)
    {
    }

    void setVideoRect(float /*posX*/, float /*poxY*/, float /*width*/, float /*height*/, float /*scale*/ = 1.0f)
    {
    }

    void addEventListener(const VideoPlayer::VideoPlayerCallback& callback)
    {
        _eventCallback = callback;
    }

    void onPlayEvent(int event)
    {
        if (_eventCallback)
        {
            _eventCallback((VideoPlayer::EventType)event);
        }
    }

    void setCallback(const std::string& /*event*/, const std::string& /*fun*/)
    {
    }

    static void executeVideoCallback(int /*index*/, int /*event*/)
    {
    }

    void executeVideoCallback(int event)
    {
        onPlayEvent(event);
    }

    static void applicationWillEnterForeground()
    {
    }

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    virtual void update(float /*dt*/)
    {
        unscheduleCompletionCallback();
        _isPlaying = false;

        VideoPlayerCallback callback = _eventCallback;
        if (callback)
        {
            callback(VideoPlayer::COMPLETED);
        }
    }
#endif

private:
    void scheduleCompletionCallback()
    {
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
        if (Director::getInstance() && Director::getInstance()->getScheduler())
        {
            Director::getInstance()->getScheduler()->scheduleUpdateForTarget(this, 0, false);
        }
        else
#endif
        {
            _isPlaying = false;
        }
    }

    void unscheduleCompletionCallback()
    {
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
        if (Director::getInstance() && Director::getInstance()->getScheduler())
        {
            Director::getInstance()->getScheduler()->unscheduleUpdateForTarget(this);
        }
#endif
    }

private:
    bool _isPlaying;
    bool _fullScreenEnabled;
    bool _keepAspectRatioEnabled;
    std::string _videoURL;
    SourceType _videoSource;
    VideoPlayerCallback _eventCallback;
};

NS_CC_END

#endif // (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#endif // __VIDEOPLAYERENGINE_H_