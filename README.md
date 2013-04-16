Listify VIM plugin
------------------

This plugin current defines 2 mappings:
- &lt;C-L> in insert mode will convert a space delimited list to a comma delimited list.
- &lt;Leader>lt in normal mode will run some tests of the helper functions

The conversion feature expects to find the list just before the current insertion point.
It should be wrapped in a pair of matching braces, parentheses or brackets. Quoted items
within the list can contain internal spaces that won't be replaced with commas. All
whitespace in the list will be removed and replaced with single spaces after the commas.

Examples:
- `[ 1 2 3 ]` will become `[1, 2, 3]`
- `("1 2 3 4" "5 6 7 8"]` will become `("1 2 3 4", "5 6 7 8")`
