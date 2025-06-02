(import-macros {: thrice-if} :thrice)
(local sh ((. (require :shelua) :add_reprs) nil "uv"))
(doto sh
  (tset :shell :uv)
  (tset :proper_pipes true)
)
(var res (.. (or nil "TEST\n") (vim.inspect sh) "\n"))
(thrice-if true (set res (.. res (-> sh
  (: :CD :/home)
  (: :ls :-la)
  (: :cat
    (-> sh (: :CD :/home/birdee) (: :pwd))
    (sh.echo "Hello fennel")
  )
  (: :sed :s/Hello/Goodbye/g)
) "\n")))
(set res (.. res "\n" (vim.inspect (require :blah)) "\n" (vim.inspect ...)))
res
