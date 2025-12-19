# AoC 2025

My attempt at [Advent of Code 2025](https://adventofcode.com/). I've never written [Zig](https://ziglang.org/) before, so this will be bad!
I'll track my progress on each day below.

## [Day 1: Secret Entrance](https://adventofcode.com/2025/day/1)

### Part 1

As you may notice from the commit, it's December 3rd. I'd like to say I've been too busy to work on this, but I'm on annual leave right now. I have spent the past 3 days figuring out how to read a file...

In my defence, Zig [recently changed how readers and writers work](https://ziglang.org/download/0.15.1/release-notes.html#New-stdIoWriter-and-stdIoReader-API), which meant most information online was old and this took me way too long to figure out.

After getting that right, it was (mostly) smooth sailing when I figured out the error system and the convoluted way to [concat strings](<https://www.xeg.io/shared-searches/a-comprehensive-guide-to-working-with-strings-in-zig-programming-language-666df7a25ccf5bab1ec23e5c#:~:text=print(%22%7B%7D%5Cn%22%2C%20.%7Bsubstring%7D)%3B%0A%7D-,String%20Concatenation,-Zig%20does%20not>).

### Part 2

Okay, this time I actually have been busy but I'm finally finding time to work on this again.

## [Day 2: Gift Shop](https://adventofcode.com/2025/day/2)

### Part 1

Yes, I realise it's day 10, I will catch up soon, I've been distracted with setting up [Omarchy](https://omarchy.org/) . For now, Zig's getting a bit more familiar, and I've got a better setup to work in now, so it's getting easier. I'm sure I'm still doing a million things wrong, but the solution came much quicker this time, with the main difficulty being reorganising the project to allow for shared util functions between files.

### Part 2

That one worked nicely, and even though it's probably not the most readable, I'm enjoying Zig's [loops as expressions](https://zig.guide/language-basics/loops-as-expressions/) way too much.

## [Day 3: Lobby](https://adventofcode.com/2025/day/3)

### Part 1

Not much to say for this one, it was pretty simple, but after a quick look at pt.2 I can tell that might require a bit more thought.

### Part 2

That didn't actually require too much adjustment from my previous method, just moving from two hard-coded values to an array where the numbers can flow down. The hardest part was finding out how to create a runtime-sized array in Zig, turns out I can't do that on the stack and I need to use an allocator to create it on the heap, makes sense, I'm just out of practice with manual memory management.

## [Day 4: Printing Department](https://adventofcode.com/2025/day/4)

### Part 1

I probably overcomplicated this a bit, but if last year is anything to go by, having some solid tools for working with grids is a must, so it was worth the effort, and I learned a lot! Including:

- I probably wasn't reading files in the best way
- I'm probably still not reading files in the best way
- How to make a struct, and make it "Generic"
- The equivalent of Generics/Templates in Zig is insane, but it actually makes a lot of sense after getting my head around it. Why shouldn't the type just be an argument? Though having a function to capture the scope of the type and return a new generic type is a little unnatural, but then generics as a whole aren't really natural to begin with.

### Part 2

That one was surprisingly easy!

## [Day 5: Cafeteria](https://adventofcode.com/2025/day/5)

### Part 1

I'm finally starting to feel a bit more comfortable with Zig now. This one wasn't too hard, just battling with compiler errors as I go.

### Part 2

I fell into the trap on this one of looping through every possible range, that didn't go well. But I think my solution of combining ranges was quite neat in the end, and I removed the inclusive/exclusive flag on my Range struct because it just caused more headaches than it was worth.

## [Day 6: Trash Compactor](https://adventofcode.com/2025/day/6)

### Part 1

I think I've finally found the "proper" way to read a file line-by-line, until tomorrow. Anyway, the problem itself was all good, just the usual battle with the compiler. But my solution does not lend itself well to part 2, I'm not looking forward to this...

### Part 2

I was so sure this would be the first time I run the code and get no compiler errors. I think I got about 20... I think the Zig LSP still requires some work, as I feel like a lot of these errors should be flagged before compilation. But I'm still enjoying using the language, it feels a lot more approachable than C++. Not much to say on the solution itself, my grid struct came in useful again.

## [Day 7: Laboratories](https://adventofcode.com/2025/day/7)

## Part 1

Something interesting I've found is that (with the exception of Day 1, which was very heavy on learning), most of the problems have taken roughly the same amount of time. It seems like as the problems get harder, my Zig improves and the two balance each other out. This was probably the quickest I got things to compile, and the problem itself was simple enough so this one was quicker than most.
