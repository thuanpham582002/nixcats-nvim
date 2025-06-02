(import-macros {: thrice-if} :thrice)
(local sh ((. (require :shelua) :add_reprs) nil "uv"))
(doto sh
  (tset :shell :uv)
  (tset :proper_pipes true)
)
(var res (.. (vim.inspect sh) "\n"))
(thrice-if true (set res (.. res (-> sh
   (: :echo "Hello fennel")
   (: :CD :/home/birdee/birdeeSystems)
   (: :sed (sh.pwd) :s/Hello/Goodbye/g)
))))
(set res (.. res "\n" (vim.inspect (require :blah)) "\n" (vim.inspect ...)))
res
