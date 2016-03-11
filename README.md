# vim-secret-markers

Remove and insert Vim's `foldmarker`s.

## What It Does

This plugin allows you to keep your markers out of version control so that the non-VIM users do not have the code cluttered with Vim  foldmarkers.

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
    # }}}
```

After running `RemoveMarkers()`, vim-secret-markers will remove all of the fold markers. It will then look like the file below.

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
```

## Requirements

For this plugin to be useful to you, these things should be true.

1. `foldmethod=marker`: I'm not really sure why you would be using this otherwise

Maybe this plugin is now `foldmarker` agnostic. I'm not sure yet. Still working on some other things currently

## Testing

Attempting to write tests with Vader. I am working on making sure it works well on Travis as well (this is my first project using it).
