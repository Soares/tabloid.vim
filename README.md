# Tabloid
## Sensational tabbing

Tabloid helps out your tabbing. It has two main uses:

1. Change the file's tabbing just how you like it. The `:TabloidFix` command
   updates the entire file to conform to your `&et`, `&sw`, and `&ts` settings.
   It's smarter than `:retab` as it only affects indentation (not, for example,
   tabs embedded in strings). It can also retain the tabbing in programming
   languages that use whitespace for indentation (`:retab` chokes on python)\*.
2. Update the existing file's tabbing. If everything is correctly tabbed but
   suddenly you decide to expand all tabs into spaces, just `:TabloidSpacify`.
   If you want to go back to tabs but make them all 6 characters wide, just
   `:TabloidTabify 6`. Toggle tab style, 3 characters wide? `:TabloidToggle 3`.
   Simple as that. Tabloid handles the `&et`, `&ts`, and `&sw` variables for
   you. (Also `&sts`, as an added bonus.)

\* If you're changing from space-indents of one width to space-indents of
another width you'll need to use `:TabloidFix N` where N is the old width of
each indent.

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

to your statusline to help you detect lines that are improperly indented.

In addition, tabloid provides the :TabloidNext and :TabloidPrev commands which
jump your cursor to nearby indentation infractions.

## Coming Soon

* Help docs
* An official vimscript
