#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
from git import Repo
from Levenshtein import distance

repo = Repo('/home/tj_chromebook/Git/vim-vertex/')

hcommit = repo.head.commit

# print(hcommit.diff('HEAD~1'))

# for diff_added in hcommit.diff('HEAD~1'):
#     for obj in dir(diff_added):
#         print(obj, ':', getattr(diff_added, obj))

# for diff_added in hcommit.diff('HEAD~1').iter_change_type('M'):
#     print(diff_added.diff)

# for line in repo.git.diff('HEAD~1').split(sep='\n'):
#     if line[0] in ['-', '+']:
#         print(line)

# print()

debug = True

# {{{ Logging configuration
logger = logging.getLogger('vim-vertex')

if debug:
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

# {{{ File Handler
fh = logging.FileHandler('./log/vim-vertex.log', mode='w')
# }}}
# {{{ Stream Handler
# }}}

# {{{ Formatters
formatter = logging.Formatter('%(name)s | %(levelname)s: %(message)s')
# }}}

fh.setFormatter(formatter)
logger.addHandler(fh)
# }}}

h1 = '979d2007e5fb828012b59a6849606c245eec7d36'
h2 = '5515357e1be31c29b8ed58b1334e2ac8e614c9aa'

file_name = 'track_line.sh'

find = "echo 'Tracking line numbers through git history'"


def get_diff(hash1, hash2, repo, debug=False):
    """
    Returns the diff object for two different hash numbers and given a repo.
    """
    c1 = repo.commit(hash1)
    c2 = repo.commit(hash2)

    return c1.diff(c2)


def get_diff_object(diff, filename, repo, debug=False):
    """
    This takes a diff object, returns the diffed text for the filename
    for a certain repo. It will print more information if you put True for debug.
    """
    if debug:
        logger.debug('Input filename: {0}'.format(filename))

    for this_diff in diff:
        if debug:
            logger.debug('Diff filenames: {0}, {1}'.format(
                this_diff.a_path, this_diff.b_path))

        # TODO(tjdevries): Handle renaming the file through diffs.
        #   Perhaps I don't need to check that both of the paths are the same
        if this_diff.a_path == filename and this_diff.b_path == filename:
            return this_diff


def get_diff_text(repo, this_diff):
    return repo.git.diff(this_diff.a_blob, this_diff.b_blob)


def find_similar_line(find, prefix, line_list):
    """
    Finds the most similar line to the line you requested.

    @param find: The line that will be compared to the other lines
    @param prefix: If None, then it is ignored,
        otherwise, the returned index must contain the prefix as the first chracter
    @param line_list: A list of strings that we are comparing to
    """
    res = [9999, 0]
    for index in range(len(line_list)):
        line = line_list[index]

        if prefix and line[0] != prefix:
            continue

        dist = distance(find, line[1:])
        if dist < res[0]:
            res = [dist, index]

    return res[1]


def find_diffed_line(find, prefix, line_list):
    """
    Finds the line number of the the line requested.

    @param find: The line that will be found
    @param prefix: The prefix of the line being search
        Use '+' as a prefix to search for lines in the newer commit.
        Use '-' to search for lines in the older commit.
    @param line_list: The list of lines of the diff

    @returns The line number in the file of the desired commit.
        -1 if not found.
    """
    a_range = [0, 0]
    b_range = [0, 0]

    lines = {'+': 0, '-': 0, ' ': 0}
    for index in range(4, len(diff_lines)):
        line = diff_lines[index]

        if line[0] not in ['+', '-', '@']:
            lines[' '] += 1
            logger.debug(line)
        elif line[0] == '@':
            a_range = [int(x) for x in line[line.index('-') + 1:line.index(' +')].split(',')]
            b_range = [int(x) for x in line[line.index('+') + 1:line.index(' @')].split(',')]
            logger.debug('a_range: {0}'.format(a_range))
            logger.debug('b_range: {0}'.format(b_range))
        elif line[0] == '+':
            lines['+'] += 1
        elif line[0] == '-':
            lines['-'] += 1

        # We have to find 'find' line,
        #   and then compute the closest line that we have after that.
        if line == prefix + find:
            logger.debug('Found `{0}`\n\tItem number {1}\n\tLine number {2}'.format(
                find, index, lines[' '] + lines[prefix]))

            return lines[' '] + lines[prefix]

current_diff = get_diff(h1, h2, repo)
diff_obj = get_diff_object(current_diff, file_name, repo, debug)
diff_text = get_diff_text(repo, diff_obj)

# {{{
if debug:
    print('================================================================================')
    print('Original')
    print('================================================================================')
    print(diff_text)
    print('================================================================================')
# }}}

diff_lines = diff_text.split('\n')

orig_line = find_diffed_line(find, '-', diff_lines)
print('Orig Line Number: {0}\n\tOrig Line: {1}'.format(orig_line, find))

new_index = find_similar_line(find, '+', diff_lines)
new_find = diff_lines[new_index][1:]
new_line = find_diffed_line(new_find, '+', diff_lines)
print('New Line Number: {0}\n\tNew Line: {1}'.format(new_line, new_find))


def get_line(line_number, prefix, diff_lines):
    """
    Gets the line that is at a certain line number for a diff
    """
    lines = {'+': 0, '-': 0, ' ': 0}
    for line in diff_lines:
        if line[0] not in ['+', '-', '@']:
            lines[' '] += 1
            logger.debug(line)
        elif line[0] == '@':
            a_range = [int(x) for x in line[line.index('-') + 1:line.index(' +')].split(',')]
            b_range = [int(x) for x in line[line.index('+') + 1:line.index(' @')].split(',')]
            logger.debug('a_range: {0}'.format(a_range))
            logger.debug('b_range: {0}'.format(b_range))
        elif line[0] == '+':
            lines['+'] += 1
        elif line[0] == '-':
            lines['-'] += 1

    return lines[' '] + lines[prefix]


def get_something():
    pass

# current_diff = c1.diff(c2)

# for this_diff in current_diff:
#     if True:  # Check the filename
#         # for obj in dir(this_diff):
#         #     print(obj, ':', getattr(this_diff, obj))
#         # print(this_diff)
#         # print(this_diff.a_blob)
#         # print(this_diff.a_mode)
#         print(repo.git.diff(this_diff.a_blob, this_diff.b_blob))

# print(repo.git.diff(h1, h2))

# for line in repo.blame('HEAD', 'README.md'):
#     if any(find in l for l in line[1]):
#         print(line)
