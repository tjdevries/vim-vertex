#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from git import Repo

repo = Repo('/home/tj_chromebook/Git/vim-vertex/')

hcommit = repo.head.commit

# print(hcommit.diff('HEAD~1'))

for diff_added in hcommit.diff('HEAD~1'):
    for obj in dir(diff_added):
        print(obj, ':', getattr(diff_added, obj))

print()

for diff_added in hcommit.diff('HEAD~1').iter_change_type('M'):
    print(diff_added.diff)

print(repo.git.diff('HEAD~1'))

print()

find = '**Vertex**: A point where two or more demarcations meet.'

for line in repo.blame('HEAD', 'README.md'):
    if any(find in l for l in line[1]):
        print(line)
