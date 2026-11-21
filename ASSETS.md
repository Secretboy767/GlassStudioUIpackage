# Assets and attribution

Glass Studio 5.0 uses the native Roblox GUI primitives provided by `GlassUI.lua` for its monogram, tab marks, rounded grip, window controls, gradients, outlines and cards.

There are no required remote images, fonts, sounds, icon downloads or executor-specific custom-asset registrations. This is intentional: the UI can render without `writefile`, `getcustomasset`, `getsynasset`, or an HTTP request for artwork.

The earlier Glass Studio prototype referenced the NorthwindUI icon atlas. This package does not redistribute that PNG; it uses the library's native text/icon fallback instead. If a future release adds the atlas, include the exact upstream license and attribution with the image.
