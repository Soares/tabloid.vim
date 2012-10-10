# Tabloid
## Sensational tabbing

Tabloid helps out your tabbing. It has two main uses:

1. Fix tabbing
2. Change tabbing


`:TabloidFix` fixes tabbing. It takes a range and it makes everything in that
range conform to your `&et`, `&sw`, and `&ts` settings. Unlike `:retab`,
`:TabloidFix` doesn't re-indent the file and it doesn't touch non-indent
characters (i.e. tabs embedded in strings). It merely changes the width and type
of each indent.


`:TabloidSpacify`, `:TabloidTabify`, and `:TabloidToggle` change your file's
tabbing once it's all consistent. They all take an arg specifying how wide to
make the new indent levels, which defaults to the current shiftwidth. So if you
want to change from tabs to spaces or visa versa,

    :TabloidToggle

will do the trick. If you want to change the file to 6-width spaces

    :TabloidSpacify 6

is for you. If you need to change it back to 2-width tabs

    :TabloidTabify 8

and then 2-width tabs

    :TabloidTabify 2

You get the picture.

## Mappings

Tabloid doesn't come with any mappings by default. However, there's a neat trick
you can do that allows you to change your file's spacing very easily:

    noremap <leader>S :<C-U>call tabloid#set(1, -1)<CR>
    noremap <leader>T :<C-U>call tabloid#set(0, -1)<CR>

Using `<C-U>` before the call and `-1` as the width tells tabloid to use the
`v:count` variable, which allows you to say

    4\S

to change the file indentation to 4 spaces (assuming \ is your leader), and

    8\T

to change the file indentation to 8-character-wide tabs. Pretty slick.

## Extras

Tabloid also provides a statusline function which will provide you statusline
warnings. Again, tabloid does not turn this on by default. We suggest you add

    set statusline+=%#sbError#
    set statusline+=%{tabloid#statusline()}
    set statusline+=*

to your statusline to help you detect lines that are improperly indented.

In addition, tabloid provides the :TabloidNext and :TabloidPrev commands which
jump your cursor to nearby indentation infractions.

## Coming Soon

* Help docs
* An official vimscript
