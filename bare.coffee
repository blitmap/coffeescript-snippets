# This redefines the extension loaders for coffeescript in node to
# compile without wrapping coffeescript in a function ((function () {})())
cf = (m.exports for path, m of require.cache when path.match /coffee-script\./)[0]

if cf
    { readFileSync } = require 'fs'

    loadFile = (module, filename) ->
        content = readFileSync filename, 'utf8'

        # strip possible byte-order mark
        if content.charCodeAt() is 0xFEFF
            content = content.slice 1

        try
            js = cf.compile content, { filename, bare: true, literate: cf.helpers.isLiterate filename }
        catch err
            throw cf.helpers.updateSyntaxError err, content, filename

        module._compile js, filename

    require.extensions[ext] = loadFile for ext in cf.FILE_EXTENSIONS
