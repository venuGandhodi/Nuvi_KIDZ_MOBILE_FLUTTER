import os

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            if 'withOpacity(' in content or 'unused_import' in content:
                # We'll just replace withOpacity
                content = content.replace('.withOpacity(', '.withValues(alpha: ')
                with open(path, 'w') as f:
                    f.write(content)
