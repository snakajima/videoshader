# VideoShader
Script-based real-time video processing technology for OpenGL/iOS

## Overview
VideoShader is a script-based video processing technology for OpenGL/iOS, which allows developers and designers to design video pipelines by combining multiple OpenGL-based video filters. 

Because each video filter is built on top of OpenGL, all video processing will be done by GPU, not involding CPU in manipulating pixels at all.

This pure GPU-based architecture allows it to process SD-video on iPhone4s, and HD-video on iPhone5 in real-time (30fps)! 

## VideoShader Script
VideoShader Script (VSScript) is the JSON-based language, which makes it very easy for developoers to describe video pipelined. At runtime, the VideoShader compiles the script into OpenGL shading language (GLSL), and executes it very efficiently. 

Here is the famous "cartoon filter" described in VSScript. 

```
{
    "title":"Cartoon I",
    "pipeline":[
        { "filter":"boxblur", "ui":{ "primary":["radius"] }, "attr":{"radius":2.0} },
        { "control":"fork" },
        { "filter":"boxblur", "attr":{"radius":2.0} },
        { "filter":"toone", "ui":{ "hidden":["weight"] } },
        { "control":"swap" },
        { "filter":"sobel" },
        { "filter":"canny_edge", "attr":{ "threshold":0.19, "thin":0.50 } },
        { "filter":"anti_alias" },
        { "blender":"alpha" }
    ]
}
```
## License

All code is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php) for free. I, however, would really appreciate if you could purchase [VideoShader Composer](https://itunes.apple.com/us/app/videoshader-composer/id764918337?mt=8), which allows you to interactively create and edit video pipelines (in VSScript). 
