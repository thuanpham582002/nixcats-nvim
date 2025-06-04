local load_w_after = require("lzextras").loaders.with_after
local MP = ...
return {
  {
    "cmp-conjure",
    for_cat = "fennel",
    on_plugin = { "conjure" },
    load = load_w_after,
  },
  {
    "conjure",
    for_cat = "fennel",
    ft = { "clojure", "fennel", "python" },
    before = function ()
      vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.nfnl"
    end,
  },
}
