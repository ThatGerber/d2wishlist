#!/usr/bin/env python3
"""
Read from stdin and try to strip out the defined tags and turn them into note tags.
"""
import fileinput
import re
import sys


class NoteMatcher:
  def __init__(self, matcher):
    self.matcher = re.compile(matcher)

  def match(self, source):
    return self.matcher.match(source)

  def convert_tags(self, note):
    result = self.match(note)
    line_prefix = result.group(1)
    new_tags = " ".join([f"#{a}" for a in result.group(3).split(',')])

    return f"{line_prefix}{new_tags}"


matcher = NoteMatcher(r"^^(\/\/notes:.*)(tags:)([a-zA-Z\-,]*)")


def main():
  source_file = sys.argv[1]

  with fileinput.FileInput(source_file, inplace=True) as file:
    for line in file:
      if matcher.match(line.rstrip()):
        print(matcher.convert_tags(line.rstrip()),end ='\n')
      else:
          print(line, end ='')

main()
