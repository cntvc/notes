# C++ 开发环境配置

## VS Code 配置
仅对当前项目生效时将配置写入文件 `.vscode/settings.json`

```json
{
    "clangd.path": "/usr/bin/clangd-19",
    "clangd.arguments": [
        // 编译器
        "--query-driver=/usr/bin/clang-19",
        // compile_commands.json 生成文件夹
        "--compile-commands-dir=${workspaceFolder}/build",
        // 后台分析并保存索引文件
        "--background-index",
        // 当 clangd 准备就绪时，用它来分析建议
        "--completion-parse=auto",
        // 让 Clangd 生成更详细的日志
        "--log=verbose",
        // 输出的 JSON 文件更美观
        "--pretty",
        // 全局补全(输入时弹出的建议将会提供 CMakeLists.txt 里配置的所有文件中可能的符号，会自动补充头文件)
        "--all-scopes-completion",
        // 建议风格：打包(重载函数只会给出一个建议）相反可以设置为detailed
        "--completion-style=bundled",
        // 跨文件重命名变量
        "--cross-file-rename",
        // 允许补充头文件
        "--header-insertion=iwyu",
        // 输入建议中，已包含头文件的项与还未包含头文件的项会以圆点加以区分
        "--header-insertion-decorators",
        // 在后台自动分析文件(基于 complie_commands，我们用CMake生成)
        "--background-index",
        // 同时开启的任务数量
        "-j=8",
        // pch优化的位置(memory 或 disk，选择memory会增加内存开销，但会提升性能)
        "--pch-storage=memory",
        // 启用这项时，补全函数时，将会给参数提供占位符，键入后按 Tab 可以切换到下一占位符，乃至函数末
        "--function-arg-placeholders=false",
        // 启用配置文件(YAML格式)
        "--enable-config",
        // 启用 Clang-Tidy 以提供「静态检查」
        "--clang-tidy",
    ],
    "clang-format.executable": "clang-format-19",
    "editor.formatOnSave": true
}
```

## .clang-format 配置

```yaml
# https://clang.llvm.org/docs/ClangFormatStyleOptions.html
---
Language: Cpp
BasedOnStyle: Google
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignArrayOfStructures: Left
AlignConsecutiveAssignments: None
AlignConsecutiveBitFields: Consecutive
AlignConsecutiveDeclarations: None
AlignConsecutiveMacros: None
AlignConsecutiveShortCaseStatements:
  Enabled: true
  AcrossEmptyLines: false
  AcrossComments: false
  AlignCaseArrows: true
  AlignCaseColons: false
AlignConsecutiveTableGenBreakingDAGArgColons: None
AlignConsecutiveTableGenCondOperatorColons: Consecutive
AlignConsecutiveTableGenDefinitionColons: None
AlignEscapedNewlines: Left
AlignOperands: Align
AlignTrailingComments: Always
AllowAllArgumentsOnNextLine: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowBreakBeforeNoexceptSpecifier: OnlyWithParen
AllowShortBlocksOnASingleLine: Empty
AllowShortCaseExpressionOnASingleLine: true
AllowShortCaseLabelsOnASingleLine: true
AllowShortCompoundRequirementOnASingleLine: true
AllowShortEnumsOnASingleLine: false
AllowShortFunctionsOnASingleLine: All
AllowShortIfStatementsOnASingleLine: WithoutElse
AllowShortLambdasOnASingleLine: All
AllowShortLoopsOnASingleLine: true
# AllowShortNamespacesOnASingleLine: true # clang-format 20
AlwaysBreakBeforeMultilineStrings: false
# 应解释为属性/限定符而非标识符的字符串宏
AttributeMacros:
  - __capability
  - __output
  - __unused
BinPackArguments: false
# BinPackLongBracedList: true # clang-format 21
BinPackParameters: true
BitFieldColonSpacing: Both
BraceWrapping:
  AfterCaseLabel: false
  AfterClass: false
  AfterControlStatement: Never
  AfterEnum: false
  AfterFunction: false
  AfterNamespace: false
  AfterObjCDeclaration: false
  AfterStruct: false
  AfterUnion: false
  AfterExternBlock: false
  BeforeCatch: false
  BeforeElse: false
  BeforeLambdaBody: false
  BeforeWhile: false
  IndentBraces: false
  SplitEmptyFunction: true
  SplitEmptyRecord: true
  SplitEmptyNamespace: true
BreakAdjacentStringLiterals: true
BreakAfterAttributes: Never
BreakAfterReturnType: Automatic
BreakArrays: false
BreakBeforeBinaryOperators: NonAssignment
BreakBeforeBraces: Attach
BreakBeforeConceptDeclarations: Always
# BreakBeforeTemplateCloser: false # clang-format 21
BreakBeforeTernaryOperators: true
# BreakBinaryOperations: OnePerLine # clang-format 20
BreakConstructorInitializers: AfterColon
BreakFunctionDefinitionParameters: false
BreakStringLiterals: true
BreakTemplateDeclarations: Yes
ColumnLimit: 100
CompactNamespaces: false
ConstructorInitializerIndentWidth: 4
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DerivePointerAlignment: true
EmptyLineAfterAccessModifier: Never
EmptyLineBeforeAccessModifier: Never
FixNamespaceComments: true
ForEachMacros:
  - foreach
  - Q_FOREACH
  - BOOST_FOREACH
IfMacros:
  - KJ_IF_MAYBE
IncludeBlocks: Regroup
IncludeCategories:
  - Regex: '^<ext/.*\.h>'
    Priority: 2
    SortPriority: 0
    CaseSensitive: false
  - Regex: '^<.*\.h>'
    Priority: 1
    SortPriority: 0
    CaseSensitive: false
  - Regex: "^<.*"
    Priority: 2
    SortPriority: 0
    CaseSensitive: false
  - Regex: ".*"
    Priority: 3
    SortPriority: 0
    CaseSensitive: false
IncludeIsMainRegex: "([-_](test|unittest))?$"
IncludeIsMainSourceRegex: ""
IndentAccessModifiers: false
IndentCaseBlocks: false
IndentCaseLabels: true
# IndentExportBlock: true # clang-format 20
IndentExternBlock: AfterExternBlock
IndentGotoLabels: false
IndentPPDirectives: None
IndentRequiresClause: false # clang-format 15 and more
IndentRequires: false # clang-format 12, 13 and 14
IndentWidth: 4
IndentWrappedFunctionNames: false
InsertNewlineAtEOF: true
InsertTrailingCommas: None
IntegerLiteralSeparator:
  Binary: 0
  Decimal: 3
  Hex: -1
LambdaBodyIndentation: Signature
# LineEnding: LF
MacroBlockBegin: ""
MacroBlockEnd: ""
# Macros:
MainIncludeChar: Any
MaxEmptyLinesToKeep: 2
NamespaceIndentation: All
# NamespaceMacros
PPIndentWidth: -1
PackConstructorInitializers: CurrentLine
PenaltyBreakAssignment: 2
PenaltyBreakBeforeFirstCallParameter: 1
PenaltyBreakComment: 300
PenaltyBreakFirstLessLess: 120
PenaltyBreakOpenParenthesis: 0
PenaltyBreakString: 1000
PenaltyBreakTemplateDeclaration: 10
PenaltyExcessCharacter: 1000000
PenaltyReturnTypeOnItsOwnLine: 200
PenaltyIndentedWhitespace: 0
PointerAlignment: Left
RawStringFormats:
  - Language: Cpp
    Delimiters:
      - cc
      - CC
      - cpp
      - Cpp
      - CPP
      - "c++"
      - "C++"
    CanonicalDelimiter: ""
    BasedOnStyle: google
  - Language: TextProto
    Delimiters:
      - pb
      - PB
      - proto
      - PROTO
    EnclosingFunctions:
      - EqualsProto
      - EquivToProto
      - PARSE_PARTIAL_TEXT_PROTO
      - PARSE_TEST_PROTO
      - PARSE_TEXT_PROTO
      - ParseTextOrDie
      - ParseTextProtoOrDie
      - ParseTestProto
      - ParsePartialTestProto
    CanonicalDelimiter: pb
    BasedOnStyle: google
ReferenceAlignment: Pointer
ReflowComments: true
RemoveBracesLLVM: false
# RemoveEmptyLinesInUnwrappedLines: true # clang-format 20
RequiresClausePosition: OwnLine
RequiresExpressionIndentation: OuterScope
SeparateDefinitionBlocks: Leave
ShortNamespaceLines: 2
SortIncludes: CaseSensitive
SortUsingDeclarations: Lexicographic
SpaceAfterCStyleCast: false
SpaceAfterLogicalNot: false
SpaceAfterTemplateKeyword: true
SpaceAroundPointerQualifiers: Default
SpaceBeforeAssignmentOperators: true
SpaceBeforeCaseColon: false
SpaceBeforeCpp11BracedList: false
SpaceBeforeCtorInitializerColon: true
SpaceBeforeInheritanceColon: true
SpaceBeforeJsonColon: true
SpaceBeforeParens: ControlStatements
SpaceBeforeParensOptions:
  AfterControlStatements: true
  AfterForeachMacros: true
  AfterFunctionDefinitionName: false
  AfterFunctionDeclarationName: false
  AfterIfMacros: true
  AfterOverloadedOperator: false
  BeforeNonEmptyParentheses: false
SpaceBeforeRangeBasedForLoopColon: true
SpaceBeforeSquareBrackets: false
SpaceInEmptyBlock: false
SpacesBeforeTrailingComments: 2
SpacesInAngles: Never
SpacesInContainerLiterals: true
SpacesInLineCommentPrefix:
  Minimum: 1
  Maximum: -1
SpacesInParens: Custom
SpacesInParensOptions:
  ExceptDoubleParentheses: true
  InConditionalStatements: false
  InEmptyParentheses: false
SpacesInSquareBrackets: false
Standard: Auto
StatementAttributeLikeMacros:
  - Q_EMIT
StatementMacros:
  - Q_UNUSED
  - QT_REQUIRE_VERSION
TabWidth: 4
TableGenBreakInsideDAGArg: DontBreak
UseTab: Never
WhitespaceSensitiveMacros:
  - STRINGIZE
  - PP_STRINGIZE
  - BOOST_PP_STRINGIZE
  - NS_SWIFT_NAME
  - CF_SWIFT_NAME
```

## .clang-tidy 配置

```yaml

---
Checks: "
  bugprone-*,
  -bugprone-exception-escape,

  clang-analyzer-*,
  concurrency-*,

  cppcoreguidelines-*,
  -cppcoreguidelines-macro-usage,
  -cppcoreguidelines-owning-memory,
  -cppcoreguidelines-avoid-magic-numbers,
  -cppcoreguidelines-pro-type-vararg,
  -cppcoreguidelines-avoid-c-arrays,
  -cppcoreguidelines-pro-bounds-pointer-arithmetic,
  -cppcoreguidelines-pro-bounds-array-to-pointer-decay,
  -cppcoreguidelines-pro-bounds-pointer-arithmetic,
  -cppcoreguidelines-pro-type-cstyle-cast,

  google-*,
  -google-readability-casting,

  hicpp-*,
  -hicpp-vararg,
  -hicpp-use-auto,
  -hicpp-no-array-decay,
  -hicpp-avoid-c-arrays,
  -hicpp-signed-bitwise,

  modernize-*,
  -modernize-use-trailing-return-type,
  -modernize-avoid-bind,
  -modernize-avoid-c-arrays,
  -modernize-use-auto,

  performance-*,

  portability-*,

  readability-*,
  -readability-identifier-length,
  -readability-magic-numbers,
  -readability-make-member-function-const,
  -readability-implicit-bool-conversion,

  "
CheckOptions:
  - { key: readability-identifier-naming.ClassCase, value: CamelCase }
  - { key: readability-identifier-naming.EnumCase, value: CamelCase }
  - { key: readability-identifier-naming.FunctionCase, value: camelBack }
  - { key: readability-identifier-naming.GlobalConstantCase, value: UPPER_CASE }
  - { key: readability-identifier-naming.MemberCase, value: lower_case }
  - { key: readability-identifier-naming.MemberSuffix, value: _ }
  - { key: readability-identifier-naming.NamespaceCase, value: lower_case }
  - { key: readability-identifier-naming.StructCase, value: CamelCase }
  - { key: readability-identifier-naming.UnionCase, value: CamelCase }
  - { key: readability-identifier-naming.VariableCase, value: lower_case }
WarningsAsErrors: "*"
HeaderFilterRegex: "src/*.(h|hpp)?"
AnalyzeTemporaryDtors: true

```
