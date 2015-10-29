_ = require 'underscore'
{ RULES: rules } = require './coffeelint'

render = () ->
    rulesHTML = ''
    ruleNames = Object.keys(rules).sort()
    for ruleName in ruleNames
        rule = rules[ruleName]
        rule.name = ruleName
        rule.description = '[no description provided]' unless rule.description
        # coffeelint: disable=no_debugger
        console.log ruleTemplate rule
        # coffeelint: enable=no_debugger

ruleTemplate = _.template '''
    <tr>
    <td class="rule"><%= name %></td>
    <td class="description">
        <%= description %>
        <p><em>default level: <%= level %></em></p>
    </td>
    </tr>
    '''

render()
