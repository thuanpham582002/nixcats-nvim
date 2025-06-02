(import-macros {: thrice-if} :thrice)
(var res "")
(thrice-if true (set res (.. res (vim.inspect (require :blah)))))
(set res (.. res (vim.inspect ...)))
res
