(fn module [name mod] (tset package.preload name mod))
(module :conjure.client.fennel.nvim (fn [name]
  (local testval 13332345)
  {:name name :testval testval})
)
