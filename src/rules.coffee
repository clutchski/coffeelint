
# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'

# CoffeeLint's default rule configuration.
module.exports =

    no_trailing_whitespace :
        level : ERROR
        message : 'Line ends with trailing whitespace'
        allowed_in_comments : false
        description: """
            This rule forbids trailing whitespace in your code, since it is
            needless cruft. It is enabled by default.
            """

    max_line_length :
        value: 80
        level : ERROR
        message : 'Line exceeds maximum allowed length'
        description: """
            This rule imposes a maximum line length on your code. <a
            href="http://www.python.org/dev/peps/pep-0008/">Python's style
            guide</a> does a good job explaining why you might want to limit the
            length of your lines, though this is a matter of taste.

            Lines can be no longer than eighty characters by default.
            """

    camel_case_classes :
        level : ERROR
        message : 'Class names should be camel cased'
        description: """
            This rule mandates that all class names are camel cased. Camel
            casing class names is a generally accepted way of distinguishing
            constructor functions - which require the 'new' prefix to behave
            properly - from plain old functions.
            <pre>
            <code># Good!
            class BoaConstrictor

            # Bad!
            class boaConstrictor
            </code>
            </pre>
            This rule is enabled by default.
            """
    indentation :
        value : 2
        level : ERROR
        message : 'Line contains inconsistent indentation'
        description: """
            This rule imposes a standard number of spaces to be used for
            indentation. Since whitespace is significant in CoffeeScript, it's
            critical that a project chooses a standard indentation format and
            stays consistent. Other roads lead to darkness. <pre> <code>#
            Enabling this option will prevent this ugly
            # but otherwise valid CoffeeScript.
            twoSpaces = () ->
              fourSpaces = () ->
                  eightSpaces = () ->
                        'this is valid CoffeeScript'

            </code>
            </pre>
            Two space indentation is enabled by default.
            """

    no_implicit_braces :
        level : IGNORE
        message : 'Implicit braces are forbidden'
        description: """
            This rule prohibits implicit braces when declaring object literals.
            Implicit braces can make code more difficult to understand,
            especially when used in combination with optional parenthesis.
            <pre>
            <code># Do you find this code ambiguous? Is it a
            # function call with three arguments or four?
            myFunction a, b, 1:2, 3:4

            # While the same code written in a more
            # explicit manner has no ambiguity.
            myFunction(a, b, {1:2, 3:4})
            </code>
            </pre>
            Implicit braces are permitted by default, since their use is
            idiomatic CoffeeScript.
            """

    no_trailing_semicolons :
        level : ERROR
        message : 'Line contains a trailing semicolon'
        description: """
            This rule prohibits trailing semicolons, since they are needless
            cruft in CoffeeScript.
            <pre>
            <code># This semicolon is meaningful.
            x = '1234'; console.log(x)

            # This semicolon is redundant.
            alert('end of line');
            </code>
            </pre>
            Trailing semicolons are forbidden by default.
            """

    no_plusplus :
        level : IGNORE
        message : 'The increment and decrement operators are forbidden'
        description: """
            This rule forbids the increment and decrement arithmetic operators.
            Some people believe the <tt>++</tt> and <tt>--</tt> to be cryptic
            and the cause of bugs due to misunderstandings of their precedence
            rules.
            This rule is disabled by default.
            """

    no_throwing_strings :
        level : ERROR
        message : 'Throwing strings is forbidden'
        description: """
            This rule forbids throwing string literals or interpolations. While
            JavaScript (and CoffeeScript by extension) allow any expression to
            be thrown, it is best to only throw <a
            href="https://developer.mozilla.org
            /en/JavaScript/Reference/Global_Objects/Error"> Error</a> objects,
            because they contain valuable debugging information like the stack
            trace. Because of JavaScript's dynamic nature, CoffeeLint cannot
            ensure you are always throwing instances of <tt>Error</tt>. It will
            only catch the simple but real case of throwing literal strings.
            <pre>
            <code># CoffeeLint will catch this:
            throw "i made a boo boo"

            # ... but not this:
            throw getSomeString()
            </code>
            </pre>
            This rule is enabled by default.
            """

    cyclomatic_complexity :
        value : 10
        level : IGNORE
        message : 'The cyclomatic complexity is too damn high'

    no_backticks :
        level : ERROR
        message : 'Backticks are forbidden'
        description: """
            Backticks allow snippets of JavaScript to be embedded in
            CoffeeScript. While some folks consider backticks useful in a few
            niche circumstances, they should be avoided because so none of
            JavaScript's "bad parts", like <tt>with</tt> and <tt>eval</tt>,
            sneak into CoffeeScript.
            This rule is enabled by default.
            """

    line_endings :
        level : IGNORE
        value : 'unix' # or 'windows'
        message : 'Line contains incorrect line endings'
        description: """
            This rule ensures your project uses only <tt>windows</tt> or
            <tt>unix</tt> line endings. This rule is disabled by default.
            """
    no_implicit_parens :
        level : IGNORE
        message : 'Implicit parens are forbidden'
        description: """
            This rule prohibits implicit parens on function calls.
            <pre>
            <code># Some folks don't like this style of coding.
            myFunction a, b, c

            # And would rather it always be written like this:
            myFunction(a, b, c)
            </code>
            </pre>
            Implicit parens are permitted by default, since their use is
            idiomatic CoffeeScript.
            """

    empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and without arguments'

    non_empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and with arguments'

    no_empty_param_list :
        level : IGNORE
        message : 'Empty parameter list is forbidden'
        description: """
            This rule prohibits empty parameter lists in function definitions.
            <pre>
            <code># The empty parameter list in here is unnecessary:
            myFunction = () -&gt;

            # We might favor this instead:
            myFunction = -&gt;
            </code>
            </pre>
            Empty parameter lists are permitted by default.
            """


    space_operators :
        level : IGNORE
        message : 'Operators must be spaced properly'

    # I don't know of any legitimate reason to define duplicate keys in an
    # object. It seems to always be a mistake, it's also a syntax error in
    # strict mode.
    # See http://jslinterrors.com/duplicate-key-a/
    duplicate_key :
        level : ERROR
        message : 'Duplicate key defined in object or class'

    newlines_after_classes :
        value : 3
        level : IGNORE
        message : 'Wrong count of newlines between a class and other code'

    no_stand_alone_at :
        level : IGNORE
        message : '@ must not be used stand alone'
        description: """
            This rule checks that no stand alone @ are in use, they are
            discouraged. Further information in CoffeScript issue <a
            href="https://github.com/jashkenas/coffee-script/issues/1601">
            #1601</a>
            """

    coffeescript_error :
        level : ERROR
        message : '' # The default coffeescript error is fine.
