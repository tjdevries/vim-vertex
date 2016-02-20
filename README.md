# vim-secret-markers

This plugin allows you to keep your markers out of version control so that the un-enlightened (i.e. not VIM users :) ) do not have the code cluttered with our markers for folding.

The main idea is that you'd like to add folding to documents that regular methods don't work out that great (i.e. indent, or maybe even expr). You might also be adding detailed section names for yourself to help you navigate the code, but aren't really necessary ("Here lie the setters", "Here lie the getters", "Here be dragons", etc.).

## How it works

Say for example you are working in a version controlled Python file in some repository that you're actually sharing with other people (this is when I got the same idea). You want to have VIM folds when you open up the file, but you have some Notepad++ guys, a Gedit guy, etc. that don't use VIM. That's where this plugin comes in handy.

## Requirements

For this plugin to be useful to you, these things should be true.

1. `foldmethod=marker`: I'm not really sure why you would be using this otherwise
2. `webapi`: JSON encoding

Maybe this plugin is now `foldmarker` agnostic. I'm not sure yet. Still working on some other things currently

## Testing

Attempting to write tests with Vader
