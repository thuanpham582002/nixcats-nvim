local sh = require('luash')
local res = sh.echo 'hello world' : sed "s/hello/goodbye/g" : cat()
print(tostring(res))
