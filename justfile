# Do not prevent local external justfile recipes from being run from cwd within the repo
set fallback

justq := quote(just_executable()) + ' -f ' + quote(justfile())
test_cases := justfile_directory() / 'tests/cases'

@_default:
	{{justq}} --list

synpreview_rtp := '-c ' + quote("let &runtimepath=\"" + justfile_directory() + ",\" . &runtimepath")

# preview JUSTFILE in Vim with syntax file from this repository
[no-cd]
preview JUSTFILE='':
	vim {{synpreview_rtp}} \
	  {{if JUSTFILE == '' { '-c "set filetype=just"' } else if path_exists(test_cases / JUSTFILE + '.just') == 'true' { quote(test_cases / JUSTFILE + '.just') } else { quote(JUSTFILE) } }}

# preview JUSTFILE in GVim with syntax file from this repository
[no-cd]
gpreview JUSTFILE='':
	gvim -f {{synpreview_rtp}} \
	  {{if JUSTFILE == '' { '-c "set filetype=just"' } else if path_exists(test_cases / JUSTFILE + '.just') == 'true' { quote(test_cases / JUSTFILE + '.just') } else { quote(JUSTFILE) } }}

# preview JUSTFILE in Neovim with syntax file from this repository
[no-cd]
npreview JUSTFILE='':
	nvim {{synpreview_rtp}} \
	  -c 'syntax on' \
	  {{if JUSTFILE == '' { '-c "set filetype=just"' } else if path_exists(test_cases / JUSTFILE + '.just') == 'true' { quote(test_cases / JUSTFILE + '.just') } else { quote(JUSTFILE) } }}


update-last-changed *force:
	#!/bin/bash
	for f in $(find * -name just.vim);do
	  gitrev="$(git log -n 1 --format='format:%H' -- "$f")"
	  if [[ {{quote(force)}} != *"$f"* ]];then
	    git show "$gitrev" | grep -q -P -i '^\+"\s*Last\s+Change:' && continue
	  fi
	  lastchange="$(git show -s "$gitrev" --format='%cd' --date='format:%Y %b %d')"
	  echo -e "$f -> Last Change: $lastchange"
	  sed --in-place -E -e "s/(^\"\s*Last\s+Change:\s+).+$/\\1${lastchange}/g" "$f"
	done



# Some functions are intentionally omitted from these lists because they're handled as special cases:
#  - error
functionsWithArgs := '''
  absolute_path
  capitalize
  clean
  env
  env_var
  env_var_or_default
  extension
  file_name
  file_stem
  join
  kebabcase
  lowercamelcase
  lowercase
  parent_directory
  path_exists
  quote
  replace
  replace_regex
  semver_matches
  sha256
  sha256_file
  shoutykebabcase
  shoutysnakecase
  snakecase
  titlecase
  trim
  trim_end
  trim_end_match
  trim_end_matches
  trim_start
  trim_start_match
  trim_start_matches
  uppercamelcase
  uppercase
  without_extension
'''
zeroArgFunctions := '''
  arch
  cache_directory
  config_directory
  config_local_directory
  data_directory
  data_local_directory
  executable_directory
  home_directory
  invocation_directory
  invocation_directory_native
  just_executable
  just_pid
  justfile
  justfile_directory
  num_cpus
  os
  os_family
  uuid
'''
allFunctions := functionsWithArgs + zeroArgFunctions

@functions:
	echo $({{justq}} --evaluate allFunctions | sort)

# generate an optimized Vim-style "very magic" regex snippet from a list of literal strings to match
optrx +strings:
	#!/usr/bin/env python3
	vparam = """{{strings}}"""
	import collections, re
	strings_list = vparam.split('|') if '|' in vparam else vparam.strip().split()
	vimSpecialChars = tuple('~@$%^&*()+=[]{}\\|<>.?')
	def vimEscape(c):
	  if type(c) is str and len(c) < 2:
	    return f'\\{c}' if c in vimSpecialChars else c
	  raise TypeError(f'{c!r} is not a character')
	charByPrefix=dict()
	for f in strings_list:
	  if len(f) < 1: continue
	  g=collections.deque(map(vimEscape, f))
	  p=charByPrefix
	  while len(g):
	    if g[0] not in p: p[g[0]] = dict()
	    p=p[g.popleft()]
	  p[''] = dict()
	def recursive_coalesce(d, addGrouping=False):
	  o=''
	  l = collections.deque(d.keys())
	  # Ensure empty string is at the end
	  if '' in l and l[-1] != '':
	    l.remove('')
	    l.append('')
	  while len(l):
	    c = l.popleft()
	    o += c
	    if len(d[c]) > 1:
	      o += recursive_coalesce(d[c], True)
	    else:
	      if len(d[c]) == 1:
	        o += recursive_coalesce(d[c])
	    if len(l):
	      o += '|'
	  # Do all items in this group have a common suffix?
	  ss=o.split('|')
	  if len(ss) > 1:
	    commonEnd = ''
	    tryCommonEnd = ss[0][:]
	    while len(tryCommonEnd):
	      c=0
	      for j in ss:
	        if re.search(r'%\((?:[^)]|\\\))+$', j):
	          # don't compare suffix in inner group to suffix of outer group
	          continue
	        c += int(j.endswith(tryCommonEnd))
	      if c == len(ss):
	        commonEnd = tryCommonEnd
	        break
	      tryCommonEnd=tryCommonEnd[1:]
	    if not(commonEnd in ('', ')?')):
	      o = '%(' + ('|'.join(map(lambda s: s[:s.rfind(commonEnd)], ss))) + ')' + commonEnd
	    elif addGrouping:
	      o = f'%({o})'
	  return o.replace('|)', ')?')
	print(recursive_coalesce(charByPrefix))

# run optrx on a variable from this justfile
@optrx_var var:
	{{justq}} optrx "$({{justq}} --evaluate {{var}})"
