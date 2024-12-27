# `tjpresent.nvim`

Hey, this is a plugin to present markdown files!!

# Usage

```lua
require("tjpresent").start_presentation {}
```

Use `n` and `p` to navigate presentation and `q` to quit.

# Purpose

This is a follow up of the set of videos of [@tjdevries](https://github.com/tjdevries) This was a gift for all of us during the advent of neovim. I'm going to create a branch for every part of the videos.

## Videos

### Part I
- Part I: https://youtu.be/VGid4aN25iI?si=Xxnm6NzAeNvoYZrF

### Part II
- Part II: https://youtu.be/AXsnL16qSyk?si=us0pIVu9laKg_wJB
- I changed little things, some comments and the variable `current_slide` for `current_slide_idx`, since `current_slide` is used in the `parse_slides` function. 
- Added a space to the separator, to detect only *header 1*
