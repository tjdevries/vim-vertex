# vim-vertex

Remove and insert Vim's `foldmarker`s.

## Why `Vim-Vertex`

**Vertex**: A point where two or more lines meet.

In terms of this plugin, a **vertex** is a place where two or more lines _of code_ meet at one point. In VIM, this one point can be considered a `fold`, and the lines are marked by `foldmarker`s, and other editors don't always take advantage of them -- as well as the fact that you may have set custom fold markers. This plugin attempts to solve this problem by giving you simple commands to both remove and add back in your own custom `foldmarker`s.

## What It Does

This plugin allows you to keep your markers out of version control (or just files you pass back and forth) so that the non-VIM users do not have the code cluttered with Vim `foldmarker`s.

The main idea is to add the capability of having `foldmarkers` inside of files, even version controlled files, but not having others have to view them. I think this is best done via example:

### Example

```python
# This is a python file

# Regular comment
def new_function():
    pass

# {{{
'''docstring here'''
# }}}

# Comment with a fold after it {{{ this stuff will go away
class NewClass:
    def __init__(self):
        pass

    # {{{ Works on nested folds
    @property
    def cool(self):
        return True
    # }}}
    # }}}
```

After running `RemoveMarkers()`, vim-vertex will remove all of the fold markers. It will then look like the file below.

```python
# This is a python file

# Regular comment
def new_function():
    pass

'''docstring here'''

# Comment with a fold after it
class NewClass:
    def __init__(self):
        pass

    @property
    def cool(self):
        return True
```

It stores the information required to place those folds back in another file (this could be changed if someone thinks of a better way!). To place them back, simply call `InsertMarkers()`. Then the file will look like its original state.

## Requirements

For this plugin to be useful to you, these things should be true.

1. `foldmethod=marker`: I'm not really sure why you would be using this otherwise

Maybe this plugin is now `foldmarker` agnostic. I'm not sure yet. Still working on some other things currently

## Testing

Attempting to write tests with Vader. I am working on making sure it works well on Travis as well (this is my first project using it).
