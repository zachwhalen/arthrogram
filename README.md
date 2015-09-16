# arthrogram

This is a program designed to generate all comic book layouts possible given a few assumptions:

- All panels are rectangular
- All panels can only have corners in predefined grid positions
- All available space on the page must be filled

I spend a lot of time thinking about how to do this, and I what I came up with is just brute force guessing. I was hoping to find how to predict the number of possible layouts given a known grid, but I haven't found the right way to express it. I even asked a mathemetician. So instead of running until that formula is satisfied, this script just runs forever. I just kill it whenever it seems like there aren't any more layouts for the current settings.

The file `out.pl` is currently set up for a nine-grid layout ( 3 by 3 ), so to use it for some other layout, change the  `$maxRow` and `$maxCol` variables accordingly, and update the `$allpoints`, `$rows` and `$columns` strings to have the right number and sequences of characters.

The output will a string formatted as a list of positions and sizes. The other file, `compile.pl`, can read that format and generate pngs following those settings.