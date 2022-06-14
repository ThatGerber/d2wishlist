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
    line_prefix = self.match(note).group(1)
    new_tags = " ".join([f"\\n#{a}" for a in self.match(note).group(3).split(',')])

    return f"{line_prefix}{new_tags}"


def main():
  source_file = sys.argv[1]
  matcher = NoteMatcher(r"^^(\/\/notes:.*)(tags:)([a-zA-Z\-,]*)")
  with fileinput.FileInput(source_file, inplace=True) as file:
    for line in file:
      if matcher.match(line.rstrip()):
        print(matcher.convert_tags(line.rstrip()),end ='\n')
      else:
          print(line, end ='')

main()
