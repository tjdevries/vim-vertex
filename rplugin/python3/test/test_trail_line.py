#!/usr/bin/env python3

import pytest

from git import Repo
from line_tracker import (
        get_diff,
        get_diff_object,
        get_diff_text,
        get_diff_text_lines,
        debug,
        find_diffed_line,
        find_similar_line
    )

# TODO: Parameterize
repo = Repo('/home/tj_chromebook/Git/vim-vertex/')


# TODO: Parameterize this somewhere, or make it not dependent on my repo?
#   Also need to add a few more examples at some point
h1 = '979d2007e5fb828012b59a6849606c245eec7d36'
h2 = '5515357e1be31c29b8ed58b1334e2ac8e614c9aa'

file_name = 'track_line.sh'

find = "echo 'Tracking line numbers through git history'"

current_diff = get_diff(h1, h2, repo)
diff_obj = get_diff_object(current_diff, file_name, repo, debug)
diff_text = get_diff_text(repo, diff_obj)
diff_lines = diff_text.split('\n')

orig_line = find_diffed_line(find, '-', diff_lines)
print('Orig Line Number: {0}\n\tOrig Line: {1}'.format(orig_line, find))

new_index = find_similar_line(find, '+', diff_lines)
new_find = diff_lines[new_index][1:]
new_line = find_diffed_line(new_find, '+', diff_lines)
print('New Line Number: {0}\n\tNew Line: {1}'.format(new_line, new_find))

example_diff = [
     "@@ -1,7 +1,5 @@",
     " #!/bin/bash",
     "-",
     "-echo 'Tracking line numbers through git history'",
     "-",
     "+echo 'Tracking line numbers through history'",
     " PARAMS=\"$*\" ",
     " LINE=$(git blame $PARAMS) ",
     " while test $? == 0 ",
     ]

class TestGetDiff:
    def test_get_diff_text(self):
        current_diff = get_diff(h1, h2, repo)
        diff_obj = get_diff_object(current_diff, file_name, repo, debug)
        diff_text = get_diff_text(repo, diff_obj)
        diff_lines = get_diff_text_lines(diff_text)

        assert diff_lines == example_diff


class TestFindSimilarLine:
    def test_small_change(self):
        find = "echo 'Tracking line numbers through history'"

        assert(3 == find_similar_line(find, '-', example_diff))


class TestFindDiffedLine:
    def test_small_change_previous_commit(self):
        find = "echo 'Tracking line numbers through history'"

        assert(2 == find_diffed_line(find, '+', example_diff))

