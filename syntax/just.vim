" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2023 Dec 29

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syn sync fromstart

syn iskeyword @,48-57,_,-

syn match justComment "\v#%([^!].*)?$" contains=@Spell,justCommentTodo
syn keyword justCommentTodo TODO FIXME XXX contained
syn match justShebang "#!.*$" contains=justInterpolation
syn match justName "\h\k*" contained
syn match justFunction "\h\k*" contained

syn match justPreBodyComment "\v%(\s|\\\n)*#%([^!].*)?\n%(\t+| +)@=" transparent contained contains=justComment
   \ nextgroup=@justBodies skipnl
syn match justPreBodyCommentError "\v^%(%(\\\n)@3<!#|(\\\n)@3<!%( +\t+|\t+ +)#).*$" contained

syn region justBacktick start=/`/ end=/`/
syn region justBacktick start=/```/ end=/```/
syn region justRawString start=/'/ end=/'/
syn region justRawString start=/'''/ end=/'''/
syn region justString start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=justLineContinuation,justStringEscapeSequence
syn region justString start=/"""/ skip=/\\\\\|\\"/ end=/"""/ contains=justLineContinuation,justStringEscapeSequence

syn cluster justStringLiterals contains=justRawString,justString
syn cluster justAllStrings contains=justBacktick,justRawString,justString

syn match justRegexReplacement /\v,%(\_s|\\\n)*%('\_[^']*'|'''%(\_.%(''')@!)*\_.?''')%(\_s|\\\n)*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn match justRegexReplacement /\v,%(\_s|\\\n)*%("%(\_[^"]|\\")*"|"""%(\_.%(""")@!)*\_.?""")%(\_s|\\\n)*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn region justRawStrRegexRepl start=/\v'/ end=/'/ contained contains=justRegexCapture
syn region justRawStrRegexRepl start=/\v'''/ end=/'''/ contained contains=justRegexCapture
syn region justStringRegexRepl start=/\v"/ skip=/\\\\\|\\"/ end=/"/ contained contains=justLineContinuation,justStringEscapeSequence,justRegexCapture
syn region justStringRegexRepl start=/\v"""/ skip=/\\\\\|\\"/ end=/"""/ contained contains=justLineContinuation,justStringEscapeSequence,justRegexCapture
syn match justRegexCapture '\v%(\$@1<!\$)@3<!\$%(\w+|\{\w+\})' contained
syn cluster justStringsWithRegexCapture contains=justRawStrRegexRepl,justStringRegexRepl

syn cluster justRawStrings contains=justRawString,justRawStrRegexRepl

syn region justStringInsideBody start=/\v\\@1<!'/ end=/'/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInsideBody start=/\v\\@1<!"/ skip=/\v\\@1<!\\"/ end=/"/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInShebangBody start=/\v\\@1<!'/ end=/'/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justShebangIndentError
syn region justStringInShebangBody start=/\v\\@1<!"/ skip=/\v\\@1<!\\"/ end=/"/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justShebangIndentError

syn match justStringEscapeSequence '\v\\[tnr"\\]' contained

syn match justAssignmentOperator "\V:=" contained

syn region justExprParen start='\V(' end='\V)' transparent contains=@justExpr
syn region justExprParenInInterp start='\V(' end='\V)' transparent contained contains=@justExprInInterp

syn match justRecipeAt "^@" contained
syn match justRecipeColon ":" contained

syn region justRecipeAttributes
   \ matchgroup=justRecipeAttr start='\v^%(\\\n)@3<!\[' end='\V]'
   \ contains=justRecipeAttr,justRecipeAttrSep,justRecipeAttrArgs,justRecipeAttrArgError

syn keyword justRecipeAttr
   \ confirm linux macos no-cd no-exit-message no-quiet private unix windows
   \ contained
syn match justRecipeAttrSep ',' contained
syn region justRecipeAttrArgs matchgroup=justRecipeAttr start='\V(' end='\V)' contained
   \ contains=@justStringLiterals
syn match justRecipeAttrArgError '\v\(%(\s|\\?\n)*\)' contained

syn match justRecipeDeclSimple "\v^\@?\h\k*%(%(\s|\\\n)*:\=@!)@="
   \ transparent contains=justRecipeName
   \ nextgroup=justRecipeNoDeps,justRecipeDeps

syn region justRecipeDeclComplex start="\v^\@?\h\k*%(\s|\\\n)+%([+*$]+%(\s|\\\n)*)*\h" end="\v%(:\=@!)@=|$"
   \ transparent
   \ contains=justRecipeName,justParameter
   \ nextgroup=justRecipeNoDeps,justRecipeDeps

syn match justRecipeName "\v^\@?\h\k*" transparent contained contains=justRecipeAt,justFunction

syn match justParameter "\v%(\s|\\\n)@3<=%(%([*+]%(\s|\\\n)*)?%(\$%(\s|\\\n)*)?|\$%(\s|\\\n)*[*+]%(\s|\\\n)*)\h\k*"
   \ transparent contained
   \ contains=justName,justVariadicPrefix,justParamExport,justVariadicPrefixError
   \ nextgroup=justPreParamValue

syn match justPreParamValue '\v%(\s|\\\n)*\=%(\s|\\\n)*'
   \ contained transparent
   \ contains=justParameterOperator
   \ nextgroup=justParamValue

syn region justParamValue contained transparent
   \ start="\v\S"
   \ skip="\\\n"
   \ end="\v%(\s|^)%([*+$:]|\h)@=|:@=|$"
   \ contains=@justAllStrings,justRecipeParenDefault,@justExprFunc
   \ nextgroup=justParameterError
syn match justParameterOperator "\V=" contained

syn match justVariadicPrefix "\v%(\s|\\\n)@3<=[*+]%(%(\s|\\\n)*\$?%(\s|\\\n)*\h)@=" contained
syn match justParamExport '\V$' contained
syn match justVariadicPrefixError "\v\$%(\s|\\\n)*[*+]" contained

syn match justParameterError "\v%(%([+*$]+%(\s|\\\n)*)*\h\k*)@>%(%(\s|\\\n)*\=)@!" contained

syn region justRecipeParenDefault
   \ matchgroup=justRecipeDepParamsParen start='\v%(\=%(\s|\\\n)*)@<=\(' end='\V)'
   \ contained
   \ contains=@justExpr
syn match justRecipeSubsequentDeps '\V&&' contained

syn match justRecipeNoDeps '\v:%(\s|\\\n)*\n|:#@=|:%(\s|\\\n)+#@='
   \ transparent contained
   \ contains=justRecipeColon
   \ nextgroup=justPreBodyComment,justPreBodyCommentError,@justBodies
syn region justRecipeDeps start="\v:%(\s|\\\n)*%([a-zA-Z_(]|\&\&)" skip='\\\n' end="\v#@=|\\@1<!\n"
   \ transparent contained
   \ contains=justFunction,justRecipeColon,justRecipeSubsequentDeps,justRecipeParamDep
   \ nextgroup=justPreBodyComment,justPreBodyCommentError,@justBodies

syn region justRecipeParamDep contained transparent
   \ matchgroup=justRecipeDepParamsParen
   \ start="\V("
   \ end="\V)"
   \ contains=justRecipeDepParenName,@justExpr

syn keyword justBoolean true false contained

syn match justAssignment "\v^\h\k*%(\s|\\\n)*:\=" transparent contains=justAssignmentOperator

syn match justSet '\v^set' contained
syn keyword justSetKeywords
   \ allow-duplicate-recipes dotenv-load dotenv-filename dotenv-path export fallback ignore-comments positional-arguments quiet shell tempdir windows-shell
   \ contained
syn keyword justSetDeprecatedKeywords windows-powershell contained
syn match justBooleanSet "\v^set%(\s|\\\n)+%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|quiet|windows-powershell)%(%(\s|\\\n)*:\=%(\s|\\\n)*%(true|false))?$"
   \ contains=justSet,justSetKeywords,justSetDeprecatedKeywords,justAssignmentOperator,justBoolean
   \ transparent

syn match justStringSet '\v^set%(\s|\\\n)+\k+%(\s|\\\n)*:\=%(\s|\\\n)*%(['"])@=' transparent contains=justSet,justSetKeywords,justAssignmentOperator

syn match justShellSet
   \ "\v^set%(\s|\\\n)+%(windows-)?shell%(\s|\\\n)*:\=%(\s|\\\n)*\[@="
   \ contains=justSet,justSetKeywords,justAssignmentOperator
   \ transparent skipwhite
   \ nextgroup=justShellSetValue
syn region justShellSetValue
   \ start='\V[' end='\V]'
   \ contained
   \ contains=@justStringLiterals,justShellSetError

syn match justShellSetError '\v\k+' contained

syn match justAlias '\v^alias' contained
syn match justAliasDecl "\v^alias%(\s|\\\n)+\h\k*%(\s|\\\n)*:\=%(\s|\\\n)*"
   \ transparent
   \ contains=justAlias,justFunction,justAssignmentOperator
   \ nextgroup=justAliasRes
syn match justAliasRes '\v\h\k*%(\s|\\\n)*%(#@=|$)' contained transparent contains=justFunction

syn match justExportedAssignment "\v^export%(\s|\\\n)+\h\k*\s*:\=" transparent
   \ contains=justExport,justAssignmentOperator

syn match justExport '\v^export' contained

syn keyword justConditional if else
syn region justConditionalBraces start="\v\{\{@!" end="\v\}@=" transparent contains=@justExpr
syn region justConditionalBracesInInterp start="\v\{\{@!" end="\v\}@=" transparent contained contains=@justExprInInterp

syn match justLineLeadingSymbol "\v^%(\\\n)@3<!\s+\zs%(\@-|-\@|\@|-)"
syn match justLineContinuation "\\$" containedin=ALLBUT,justComment,justShebang,@justRawStrings,justPreBodyCommentError,justRecipeAttrArgError

syn region justBody
   \ start=/\v^\z( +|\t+)%(#!)@!\S/
   \ skip='\\\n' end="\v\n\z1@!"
   \ contains=justInterpolation,@justOtherCurlyBraces,justLineLeadingSymbol,justLineContinuation,justComment,justStringInsideBody,justIndentError
   \ contained

syn region justShebangBody
   \ start="\v^\z( +|\t+)#!"
   \ skip='\\\n' end="\v\n\z1@!"
   \ contains=justInterpolation,@justOtherCurlyBraces,justLineContinuation,justComment,justShebang,justStringInShebangBody,justShebangIndentError
   \ contained

syn cluster justBodies contains=justBody,justShebangBody

syn match justIndentError '\v^%(\\\n)@3<!%( +\zs\t|\t+\zs )\s*'
syn match justShebangIndentError '\v^ +\zs\t\s*'

syn region justInterpolation
   \ matchgroup=justInterpolationDelim
   \ start="\v%(^\z(\s+)@>.*)@<=\{\{\{@!" end="\v%(%(\\\n\z1|\S)\s*)@<=\}\}|$"
   \ contained
   \ contains=@justExprInInterp

syn match justBadCurlyBraces '\v\{{3}\ze[^{]' contained
syn match justCurlyBraces '\v\{{4}' contained
syn match justBadCurlyBraces '\v\{{5}\ze[^{]' contained
syn cluster justOtherCurlyBraces contains=justCurlyBraces,justBadCurlyBraces

syn match justFunctionCall "\v\w+%(\s|\\\n)*\(@=" transparent contains=justBuiltInFunction

syn keyword justBuiltInFunction
   \ absolute_path arch cache_directory capitalize clean config_directory config_local_directory data_directory data_local_directory env env_var env_var_or_default executable_directory extension file_name file_stem home_directory invocation_directory invocation_directory_native join just_executable justfile justfile_directory just_pid kebabcase lowercamelcase lowercase num_cpus os os_family parent_directory path_exists quote replace replace_regex semver_matches sha256 sha256_file shoutykebabcase shoutysnakecase snakecase titlecase trim trim_end trim_end_match trim_end_matches trim_start trim_start_match trim_start_matches uppercamelcase uppercase uuid without_extension
   \ contained

syn match justUserDefinedError "\verror%(%(\s|\\\n)*\()@="

syn match justReplaceRegex '\vreplace_regex%(\s|\\\n)*\(@=' transparent contains=justBuiltInFunction nextgroup=justReplaceRegexCall
syn match justReplaceRegexInInterp '\vreplace_regex%(\s|\\\n)*\(@=' transparent contains=justBuiltInFunction nextgroup=justReplaceRegexCallInInterp

syn region justReplaceRegexCall
   \ matchgroup=justReplaceRegexCall
   \ start='\V(' end='\V)'
   \ transparent contained
   \ contains=@justExpr,justRegexReplacement
syn region justReplaceRegexCallInInterp
   \ matchgroup=justReplaceRegexCall
   \ start='\V(' end='\V)'
   \ transparent contained
   \ contains=@justExprInInterp,justRegexReplacement

syn match justParameterLineContinuation '\v%(\s|\\\n)*' contained nextgroup=justParameterError

syn match justRecipeDepParenName '\v%(\(%(\s|\\\n)*)@<=\h\k*'
   \ transparent contained
   \ contains=justFunction

syn cluster justBuiltInFunctions contains=justFunctionCall,justUserDefinedError

syn match justOperator "\V=="
syn match justOperator "\V!="
syn match justOperator "\V=~"
syn match justOperator "\V+"
syn match justOperator "\V/"

syn cluster justExprBase contains=@justAllStrings,@justBuiltInFunctions,justConditional,justOperator
syn cluster justExpr contains=@justExprBase,justExprParen,justConditionalBraces,justReplaceRegex
syn cluster justExprInInterp contains=@justExprBase,justName,justExprParenInInterp,justConditionalBracesInInterp,justReplaceRegexInInterp

syn cluster justExprFunc contains=@justBuiltInFunctions,justReplaceRegex,justExprParen

syn match justImport /\v^import%(%(\s|\\\n)*\?|%(\s|\\\n)+['"]@=)/ transparent
   \ contains=justImportStatement,justOptionalFile
syn match justImportStatement '^import' contained

syn match justOldInclude "^!include"

syn match justModule /\v^mod%(%(\s|\\\n)*\?)?%(\s|\\\n)+\h\k*\s*%($|%(\s|\\\n)+['"]@=)/
   \ transparent contains=justModStatement,justName,justOptionalFile
syn match justModStatement '^mod' contained

syn match justOptionalFile '\V?' contained

hi def link justAlias                 Statement
hi def link justAssignmentOperator    Operator
hi def link justBacktick              Special
hi def link justBadCurlyBraces        Error
hi def link justBody                  Number
hi def link justBoolean               Boolean
hi def link justBuiltInFunction       Function
hi def link justComment               Comment
hi def link justCommentTodo           Todo
hi def link justConditional           Conditional
hi def link justCurlyBraces           Special
hi def link justExport                Statement
hi def link justFunction              Function
hi def link justImportStatement       Include
hi def link justIndentError           Error
hi def link justInterpolation         Normal
hi def link justInterpolationDelim    Delimiter
hi def link justLineContinuation      Special
hi def link justLineLeadingSymbol     Special
hi def link justModStatement          Keyword
hi def link justName                  Identifier
hi def link justOldInclude            Error
hi def link justOperator              Operator
hi def link justOptionalFile          Conditional
hi def link justParameterError        Error
hi def link justParameterOperator     Operator
hi def link justParamExport           Statement
hi def link justPreBodyCommentError   Error
hi def link justRawString             String
hi def link justRawStrRegexRepl       String
hi def link justRecipeAt              Special
hi def link justRecipeAttr            Type
hi def link justRecipeAttrArgError    Error
hi def link justRecipeAttrSep         Operator
hi def link justRecipeColon           Operator
hi def link justRecipeDepParamsParen  Delimiter
hi def link justRecipeSubsequentDeps  Operator
hi def link justRegexCapture          Constant
hi def link justSet                   Statement
hi def link justSetDeprecatedKeywords Underlined
hi def link justSetKeywords           Keyword
hi def link justShebang               SpecialComment
hi def link justShebangBody           Number
hi def link justShebangIndentError    Error
hi def link justShellSetError         Error
hi def link justString                String
hi def link justStringEscapeSequence  Special
hi def link justStringInShebangBody   String
hi def link justStringInsideBody      String
hi def link justStringRegexRepl       String
hi def link justUserDefinedError      Exception
hi def link justVariadicPrefix        Statement
hi def link justVariadicPrefixError   Error
