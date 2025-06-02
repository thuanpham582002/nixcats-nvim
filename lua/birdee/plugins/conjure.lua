local load_w_after = require("lzextras").loaders.with_after
return {
  {
    "cmp-conjure",
    for_cat = "fennel",
    on_plugin = { "conjure" },
    -- on_plugin = { "blink.cmp" },
    load = load_w_after,
  },
  {
    "conjure",
    for_cat = "fennel",
    ft = { "clojure", "fennel", "python" },
    before = function ()
    end,
    after = function ()
    end,
  },
}
