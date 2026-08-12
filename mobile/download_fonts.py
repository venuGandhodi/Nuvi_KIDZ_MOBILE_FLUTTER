import urllib.request
import os

urls = {
    'Quicksand-VariableFont_wght.ttf': 'https://github.com/google/fonts/raw/main/ofl/quicksand/Quicksand%5Bwght%5D.ttf',
    'BeVietnamPro-Regular.ttf': 'https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Regular.ttf',
    'BeVietnamPro-Medium.ttf': 'https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Medium.ttf',
    'BeVietnamPro-SemiBold.ttf': 'https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-SemiBold.ttf',
    'BeVietnamPro-Bold.ttf': 'https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Bold.ttf',
}

os.makedirs('assets/fonts', exist_ok=True)
for filename, url in urls.items():
    print(f"Downloading {filename}...")
    urllib.request.urlretrieve(url, f"assets/fonts/{filename}")
print("Done!")
