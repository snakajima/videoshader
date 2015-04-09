{
    "fork": {
        "type":"control",
        "title":"Duplicate",
        "description":"Duplicate the topmost layer",
    },
    "swap": {
        "type":"control",
        "title":"Swap",
        "description":"Swap two topmost layers",
    },
    "shift": {
        "type":"control",
        "title":"Shift",
        "description":"Shift the topmost layer to the bottom",
    },
    "simple": {
        "type":"filter",
        "title":"Null",
        "description":"Null",
        "hidden":true,
    },
    "mono": {
        "type":"filter",
        "title":"Monochrome",
        "description":"Convert to monochrome color",
        "attr" : {
            "color": {
                "default":[ 1.0, 1.0, 1.0, 1.0 ],
            },
            "weight": {
                "default":[ 0.299, 0.587, 0.114 ],
            },
        },
    },
    "gradientmap": {
        "type":"filter",
        "title":"Gradient Map",
        "description":"Mix two colors using brightness",
        "attr" : {
            "color1": {
                "default":[ 0.0, 0.0, 0.0, 0.0 ],
            },
            "color2": {
                "default":[ 1.0, 1.0, 1.0, 1.0 ],
            },
            "weight": {
                "default":[ 0.299, 0.587, 0.114 ],
            },
        },
    },
    "halftone": {
        "type":"filter",
        "title":"Half Tone",
        "description":"Convert to halftone color",
        "attr" : {
            "color1": {
                "default":[ 0.0, 0.0, 0.0, 1.0 ],
            },
            "color2": {
                "default":[ 1.0, 1.0, 1.0, 0.0 ],
            },
            "weight": {
                "default":[ 0.299, 0.587, 0.114 ],
            },
            "radius": {
                "default": 5.0,
                "range":[2.0, 100.0],
            },
            "scale": {
                "default": 1.3,
                "range":[0.1, 2.0],
            },
        },
    },
    "toone": {
        "type":"filter",
        "title":"Toone",
        "attr" : {
            "levels": {
                "default":4.0,
                "range":[ 2.0, 8.0 ],
            },
            "weight": {
                "default":[ 0.299, 0.587, 0.114 ],
            },
        },
        "description":"Convert colors to multiple levels",
    },
    "boxblur": {
        "type":"filter",
        "title":"Box Blur",
        "blur":true,
        "vertex":"blur",
        "description":"Box Blur",
        "attr" : {
            "radius": {
                "default":4.0,
                "range":[1.0, 64.0],
            },
        },
    },
    "gaussianblur": {
        "type":"filter",
        "title":"Gaussian Blur",
        "blur":true,
        "vertex":"blur",
        "description":"Gaussian Blur",
        "attr" : {
            "radius": {
                "default":4.0,
                "range":[1.0, 64.0],
            },
        },
    },
    "tint": {
        "type":"filter",
        "title":"Tint",
        "description":"Tint with a color",
        "attr" : {
            "ratio": {
                "default":0.5,
            },
            "color": {
                "default":[0.0, 0.0, 0.0, 1.0],
            },
        },
    },
    "enhancer": {
        "type":"filter",
        "title":"Enhancer",
        "description":"Enhance each color component",
        "attr" : {
            "red": {
                "default":[0.0, 1.0],
            },
            "green": {
                "default":[0.0, 1.0],
            },
            "blue": {
                "default":[0.0, 1.0],
            },
        },
    },
    "blur": {
        "type":"filter",
        "hidden":true,
        "title":"Box Blur (OLD)",
        "vertex":"convolve",
        "description":"TBF",
    },
    "hue_filter": {
        "type":"filter",
        "title":"Hue Detector",
        "description":"detect",
        "attr": {
            "hue": {
                "default":[0.0, 180.0],
                "range":[0.0, 360.0],
            },
            "chroma": {
                "default":[0.2, 1.0],
            },
        },
    },
    "mixer": {
        "type":"mixer",
        "title":"Mixer",
        "description":"Mix two layers using third layer's alpha",
    },
    "invert": {
        "type":"filter",
        "title":"Invert",
        "description":"Invert the color",
    },
    "alpha": {
        "type":"blender",
        "title":"Alpha",
        "description":"Alpha blend two layers",
        "attr": {
            "ratio": {
                "default":1.0,
            },
        },
    },
    "altalpha": {
        "type":"blender",
        "title":"Alternate Alpha",
        "description":"Alternate Alpha blend",
        "attr": {
            "ratio1": {
                "default":0.0,
            },
            "ratio2": {
                "default":1.0,
            },
            "tempo": {
                "default":120.0,
                "range":[30.0, 240.0],
            },
        },
    },
    "alphamask": {
        "type":"blender",
        "title":"Alpha Mask",
        "description":"Alpha mask one layer with another",
    },
    "contrast": {
        "type":"filter",
        "title":"Contrast",
        "description":"Change the contrast",
        "attr": {
            "enhance": {
                "default":0.5,
            },
        },
    },
    "sobel": {
        "type":"filter",
        "title":"Sobel",
        "description":"Sobel operator (for Canny Edge Detector)",
        "vertex":"convolve",
        "attr": {
            "weight": {
                "default":2.0,
                "range":[0.0, 4.0],
            },
        },
    },
    "canny_edge": {
        "type":"filter",
        "title":"Canny Edge Detector",
        "description":"*Apply after Sobel filter to detect edge",
        "vertex":"convolve",
        "attr": {
            "threshold": {
                "default":0.21,
            },
            "thin": {
                "default":0.0,
            },
            "color": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
        },
    },
    "lighter": {
        "type":"filter",
        "title":"Lighter",
        "description":"Make the color lighter",
        "attr": {
            "ratio": {
                "default":0.5,
                "range":[0.0, 30.0],
            },
        },
    },
    "hueshift": {
        "type":"filter",
        "title":"Hue Shifter",
        "description":"Shift Hue",
        "attr": {
            "shift": {
                "default":180.0,
                "range":[0.0, 360.0],
            },
        },
    },
    "multiply": {
        "type":"blender",
        "title":"Multiply",
        "description":"Multiply-blend two layers",
    },
    "screen": {
        "type":"blender",
        "title":"Screen",
        "description":"Screen-blend two layers",
    },
    "lighten": {
        "type":"blender",
        "title":"Lighten",
        "description":"Lighter-blend two layers",
    },
    "darken": {
        "type":"blender",
        "title":"Darken",
        "description":"Darken-blend two layers",
    },
    "overlay": {
        "type":"blender",
        "title":"Overlay",
        "description":"Muitply or screen blend two layers",
    },
    "colordodge": {
        "type":"blender",
        "title":"Color Dodge",
        "description":"Color dodge blend two layers",
    },
    "colorburn": {
        "type":"blender",
        "title":"Color Burn",
        "description":"Color burn blend two layers",
    },
    "hardlight": {
        "type":"blender",
        "title":"Hard Light",
        "description":"Hard light blend two layers",
    },
    "softlight": {
        "type":"blender",
        "title":"Soft Light",
        "description":"Soft light blend two layers",
    },
    "difference": {
        "type":"blender",
        "title":"Difference",
        "description":"Difference blend two layers",
    },
    "differentiate": {
        "type":"blender",
        "title":"Differentiate",
        "description":"Enlarge the difference between two layers",
        "attr": {
            "ratio": {
                "default": 0.5,
                "range":[0.0, 10.0],
            },
        },
    },
    "exclusion": {
        "type":"blender",
        "title":"Exclusion",
        "description":"Exclusion blend two layers",
    },
    "hue": {
        "type":"blender",
        "title":"Hue",
        "description":"Hue blend two layers",
    },
    "saturation": {
        "type":"blender",
        "title":"Saturation",
        "description":"Saturation blend two layers",
    },
    "colorblend": {
        "type":"blender",
        "title":"Color",
        "description":"Color blend two layers",
    },
    "luminosity": {
        "type":"blender",
        "title":"Luminosity",
        "description":"Luminosity blend two layers",
    },
    "alpha_center": {
        "type":"blender",
        "title":"Alpha Center",
        "hidden":true,
        "description":"Use circle source",
        "attr": {
            "radius": {
                "default":1.0,
            },
            "power": {
                "default":1.0,
            },
        },
    },
    "tone_curve_6": {
        "type":"filter",
        "title":"Tone Curve 6",
        "hidden":true,
        "description":"TBF",
    },
    "boolean": {
        "type":"filter",
        "title":"Boolean",
        "description":"Alternate color based on weighted monochrome",
        "attr": {
            "range": {
                "default":[0.0, 0.5],
            },
            "weight": {
                "default":[ 0.299, 0.587, 0.114 ],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 0.0],
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0],
            },
        },
    },
    "anti_alias": {
        "type":"filter",
        "title":"Anti Alias",
        "description":"Anti Alias",
        "vertex":"convolve",
    },
    "saturate": {
        "type":"filter",
        "title":"Saturate",
        "description":"Saturate/desaturate the color",
        "attr": {
            "ratio": {
                "default":0.5,
                "range":[-1.0, 1.0],
            },
            "weight": {
                "default":[0.2126,0.7152,0.0722],
            },
        },
    },
    "stretch": {
        "type":"filter",
        "title":"Stretch",
        "description":"Stretch x or y direction",
        "vertex":"stretch",
        "attr": {
            "ratio": {
                "default":[1.0, 1.0],
                "range":[1.0, 2.0],
            },
        },
    },
    "max_blur": {
        "type":"filter",
        "title":"Max Box Blur",
        "description":"Maximum value of 9 adjacent pixels",
        "vertex":"convolve",
    },
    "max_blur_cross": {
        "type":"filter",
        "title":"Max Cross Blur",
        "description":"Maximum value of 5 adjacent pixels",
        "vertex":"convolve",
    },
    "texture": {
        "type":"source",
        "title":"Texture",
        "description":"Generate Texture",
        "texture":true,
        "hidden":true,
        "attr": {
            "texture": {
                "default":"vmark_logo"
            },
        },
    },
    "superimpose": {
        "type":"filter",
        "title":"Superimpose",
        "description":"Superimpose Texture",
        "texture":true,
        "hidden":true,
        "attr": {
            "texture": {
                "default":"vmark_logo"
            },
            "ratio": {
                "default":1.0,
            },
            "scale": {
                "default":0.1875,
                "range":[0.1, 10.0],
            },
        },
    },
    "watermark": {
        "type":"filter",
        "title":"watermark",
        "description":"Watermark Logo",
        "texture":true,
        "hidden":true,
        "orientation":true,
        "attr": {
            "texture": {
                "default":"vmark_logo"
            },
            "ratio": {
                "default":1.0,
            },
            "scale": {
                "default":0.1875,
                "range":[0.1, 10.0],
            },
        },
    },
    "color": {
        "type":"source",
        "title":"Solid Color",
        "description":"Generate a colored layer",
        "attr": {
            "color": {
                "default":[1.0, 1.0, 1.0, 1.0]
            },
        },
    },
    "altcolor": {
        "type":"source",
        "title":"Alternate Color",
        "description":"Generate time-alternate colored layer",
        "attr": {
            "color1": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
            "color2": {
                "default":[1.0, 1.0, 1.0, 1.0]
            },
            "tempo": {
                "default":120.0,
                "range":[30.0, 240.0],
            },
        },
    },
    "wave": {
        "type":"source",
        "title":"Wave Color",
        "description":"Generate wave colored layer",
        "attr": {
            "center": {
                "default":[0.5, 0.5],
                "range":[-10.0, 10.0],
            },
            "scale": {
                "default":[1.0, 1.0],
                "range":[0.0, 1.0],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
            "color2": {
                "default":[1.0, 1.0, 1.0, 1.0]
            },
            "speed": {
                "default":0.0,
                "range":[-10.0, 10.0],
            },
            "wave": {
                "default":10.0,
                "range":[0.0, 30.0],
            },
        },
    },
    "rainbow": {
        "type":"source",
        "title":"Rainbow Color",
        "description":"Generate rainbow colored layer",
        "attr": {
            "center": {
                "default":[0.5, 0.5],
                "range":[-10.0, 10.0],
            },
            "scale": {
                "default":[1.0, 1.0],
                "range":[0.0, 1.0],
            },
            "speed": {
                "default":0.0,
                "range":[-10.0, 10.0],
            },
            "wave": {
                "default":10.0,
                "range":[0.0, 30.0],
            },
            "alpha": {
                "default":1.0,
            },
            "lightness": {
                "default":0.5,
            },
            "saturation": {
                "default":1.0,
            },
        },
    },
    "checker": {
        "type":"source",
        "title":"Checkerboard",
        "description":"Generate a checkerboard layer",
        "vertex":"aspect",
        "attr": {
            "angle": {
                "default":0.0,
                "range":[-3.14159265, 3.14159265],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 0.0]
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
            "count": {
                "default":8.0,
                "range":[2.0, 100.0],
            },
        },
    },
    "slice": {
        "type":"source",
        "title":"Slice",
        "description":"Generate a sliced two-color layer",
        "attr": {
            "angle": {
                "default":0.0,
                "range":[-3.14159265, 3.14159265],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 0.0]
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
            "center": {
                "default":[0.5, 0.5]
            },
        },
    },
    "gradient": {
        "type":"source",
        "title":"Gradient",
        "vertex":"rotation",
        "description":"Generate a gradient layer",
        "attr": {
            "angle": {
                "default":0.0,
                "range":[-3.14159265, 3.14159265],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 0.0]
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
        },
    },
    "circle": {
        "type":"source",
        "title":"Circuler Edge",
        "description":"Generate a circular two-color layer",
        "attr": {
            "radius": {
                "default":1.0,
                "range":[0.0, 2.0],
            },
            "power": {
                "default":1.0,
                "range":[0.0, 30.0],
            },
            "color1": {
                "default":[0.0, 0.0, 0.0, 0.0]
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0]
            },
        },
    },
    "tilt_shift": {
        "type":"filter",
        "title":"Tilt Shift",
        "description":"Miniature faking",
        "blur":true,
        "orientation":true,
        "vertex":"blur",
        "attr" : {
            "radius": {
                "default":16.0,
                "range":[8.0, 24.0],
            },
            "factor": {
                "default":2.0,
                "range":[0.5, 3.0],
            },
            "position": {
                "default":0.5,
                "range":[0.0, 1.0],
            },
        },
    },
    "emboss" : {
        "type":"filter",
        "title":"Emboss",
        "description":"*Apply after Sobel filter",
        "attr": {
            "rotation" : {
                "default":0.0,
                "range":[-3.14159265, 3.14159265]
            }
        }
    },
    "mirror" : {
        "type":"filter",
        "title":"Mirror",
        "description":"Reflection",
        "attr": {
            "rotation" : {
                "default":0.0,
                "range":[-3.14159265, 3.14159265]
            }
        }
    },
    "previous": {
        "type":"control",
        "title":"Previous",
        "description":"Texture from previous frame",
    },
    "delta": {
        "type":"blender",
        "title":"Delta Detector",
        "description":"Detect delta between two textures",
        "attr": {
            "delta": {
                "default":0.333,
            },
            "color1": {
                "default":[1.0, 1.0, 1.0, 1.0],
            },
            "color2": {
                "default":[0.0, 0.0, 0.0, 1.0],
            },
        },
    },
    "copy" : {
        "type":"filter",
        "title":"Copy",
        "description":"Copy Texture",
        "attr": {
        }
    },
    "loudness": {
        "type":"blender",
        "title":"Audio Loudness",
        "description":"Blend two textures based on loudness",
        "audio":true,
        "attr": {
            "range": {
                "default":[0.0, 0.2],
            },
        },
    },
    "embold": {
        "type":"filter",
        "title":"Embold",
        "blur":true,
        "vertex":"blur",
        "description":"Embold",
        "attr" : {
            "radius": {
                "default":4.0,
                "range":[1.0, 8.0],
            },
        },
    },
    "invertalpha": {
        "type":"filter",
        "title":"Invert Alpha",
        "description":"Invert the alpha channel",
    },
    "colortracker": {
        "type":"blender",
        "title":"Color Tracker",
        "description":"Tracks a specified color",
        "attr": {
            "ratio": {
                "default":0.95,
                "range":[0.75, 1.0]
            },
            "color": {
                "default":[1.0, 1.0, 0.12],
            },
            "range": {
                "default":[0.34, 0.8],
            },
        },
    },
    "offset": {
        "type":"filter",
        "title":"Offset",
        "vertex":"offset",
        "description":"Texture Offset",
        "attr": {
            "offset": {
                "default":[0.0, 0.0],
                "range":[-1.0, 1.0]
            },
        },
    },
    "timedzoom": {
        "type":"filter",
        "title":"Timed Zoom",
        "description":"Zoom in/out slowly",
        "vertex":"timedzoom",
        "attr": {
            "zoom": {
                "default":1.1,
                "range":[0.5, 2.0],
            },
            "center": {
                "default":[0.5, 0.5],
            },
        },
    },
    "rotation": {
        "type":"filter",
        "title":"Rotation",
        "vertex":"rotation",
        "description":"Rotation",
        "attr": {
            "rotation": {
                "default":0.0,
                "range":[-3.14159265, 3.14159265]
            },
        },
    },
}