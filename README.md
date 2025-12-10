# AoC 2025

My attempt at Advent of Code 2025. I've never written Zig before, so this will be bad!
I'll track my progress on each day below.

## Day 1

### Part 1

As you may notice from the commit, it's December 3rd. I'd like to say I've been too busy to work on this, but I'm on annual leave right now. I have spent the past 3 days figuring out how to read a file...

In my defence, Zig [recently changed how readers and writers work](https://ziglang.org/download/0.15.1/release-notes.html#New-stdIoWriter-and-stdIoReader-API), which meant most information online was old and this took me way too long to figure out.

After getting that right, it was (mostly) smooth sailing when I figured out the error system and the convoluted way to [concat strings](<https://www.xeg.io/shared-searches/a-comprehensive-guide-to-working-with-strings-in-zig-programming-language-666df7a25ccf5bab1ec23e5c#:~:text=print(%22%7B%7D%5Cn%22%2C%20.%7Bsubstring%7D)%3B%0A%7D-,String%20Concatenation,-Zig%20does%20not>).

### Part 2

Okay, this time I actually have been busy but I'm finally finding time to work on this again.

## Day 2

### Part 1

Yes, I realise it's day 10, I will catch up soon, I've been distracted with setting up [Omarchy](https://omarchy.org/) . For now, Zig's getting a bit more familiar, and I've got a better setup to work in now, so it's getting easier. I'm sure I'm still doing a million things wrong, but the solution came much quicker this time, with the main difficulty being reorganising the project to allow for shared util functions between files.
