from PIL import Image, ImageFilter

path = r'c:\Users\islam\Desktop\work\PinPic\pinpic\images\bgcunb\4.png'
im = Image.open(path).convert('RGB')
w, h = im.size
px = im.load()

samples = []
for y in list(range(0, 50)) + list(range(h - 50, h)):
    for x in range(0, w, 2):
        samples.append(px[x, y])
br = sorted(s[0] for s in samples)[len(samples) // 2]
bgc = sorted(s[1] for s in samples)[len(samples) // 2]
bb = sorted(s[2] for s in samples)[len(samples) // 2]
# force near-black consistent with onboarding
br, bgc, bb = 5, 5, 14
print('bg', br, bgc, bb)

mask = Image.new('L', (w, h), 0)
mp = mask.load()
for y in range(h):
    for x in range(w):
        r, g, b = px[x, y]
        lum = (r + g + b) / 3.0
        sat = max(r, g, b) - min(r, g, b)
        # Keep only real tile content, not dark ghosts/glow
        if lum >= 48 or (lum >= 32 and sat >= 40):
            mp[x, y] = 255

# Grow slightly to keep tile borders
mask = mask.filter(ImageFilter.MaxFilter(5))
mask = mask.filter(ImageFilter.MedianFilter(3))

clean = Image.new('RGB', (w, h), (br, bgc, bb))
edge = mask.filter(ImageFilter.GaussianBlur(0.8))
out = Image.composite(im, clean, edge)
out.save(path, optimize=True)
mask.save(r'c:\Users\islam\Desktop\work\PinPic\pinpic\tool\4_mask.png')
print('saved clean flat bg + tiles only')
