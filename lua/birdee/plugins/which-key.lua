return {
  {
    "which-key.nvim",
    -- cmd = { "" },
    for_cat = "other",
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (_)
      require('which-key').setup({})
      local leaderCmsg
      if nixCats('AI') then
        leaderCmsg = "[c]olor [p]icker (and [c]lippy)"
      else
        leaderCmsg = "[c]olor [p]icker"
      end
      require('which-key').add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>1", desc = "File Explorer (Snacks)" },
        { "<leader>F", group = "[F]ormat" },
        { "<leader>F_", hidden = true },
        { "<leader>c", group = leaderCmsg },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[G]it" },
        { "<leader>g_", hidden = true },
        { "<leader>l", group = "[L]SP" },
        { "<leader>l_", hidden = true },
        { "<leader>h", group = "[H]arpoon" },
        { "<leader>h_", hidden = true },
        { "<leader>m", group = "[M]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>f", group = "[S]earch [F]ind" },
        { "<leader>f_", hidden = true },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>w_", hidden = true },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>t_", hidden = true },
        { "<leader>a", group = "[A]I Assistant" },
        { "<leader>a_", hidden = true },
      }
    end,
  },
}
