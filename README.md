# Tabloid
## Sensational tabbing

Tabloid helps out your tabbing. It has two main uses:

1. Fix tabbing
2. Change tabbing

`:TabloidFix` fixes tabbing, making everything in a given range conform to your
current 'expandtab', 'shiftwidth', and 'tabstop' settings.

`:TabloidSpacify` and `:TabloidTabify` change tabbing once it's consistent. They
take a `count` specifying how wide to make the new indent levels, and with some
clever mappings they make it very easy to change the indentation in any file.

See ':help tabloid' for key mappings, statusline integration, extra commands,
and more.
