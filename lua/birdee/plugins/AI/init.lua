local MP = ...
local isNixCats = require('nixCatsUtils')
return {
  {
    "AI_auths",
    enabled = isNixCats and (nixCats("AI.windsurf") or nixCats("AI.minuet") or nixCats("AI.aider")) or false,
    dep_of = { "windsurf.nvim", "minuet-ai.nvim", "nvim-aider", "opencode.nvim" },
    load = function(_)
      local bitwardenAuths = nixCats.extra('bitwarden_uuids')
      local windsurfDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local windsurfAuthFile = windsurfDir .. '/' .. 'config.json'
      local windsurfAuthInvalid = vim.fn.filereadable(windsurfAuthFile) == 0
      require('birdee.utils').get_auths({
        windsurf = {
          enable = isNixCats and windsurfAuthInvalid and bitwardenAuths.windsurf and nixCats("AI.windsurf") or false,
          cache = false, -- <- this one is cached by its action
          bw_id = bitwardenAuths.windsurf,
          localpath = (os.getenv("HOME") or "~") .. "/.secrets/windsurf",
          action = function (key)
            if vim.fn.isdirectory(windsurfDir) == 0 then
              vim.fn.mkdir(windsurfDir, 'p')
            end
            if (string.len(key) > 10) then
              local file = io.open(windsurfAuthFile, 'w')
              if file then
                file:write('{"api_key": "' .. key .. '"}')
                file:close()
                vim.loop.fs_chmod(windsurfAuthFile, 384, function(err, success)
                  if err then
                    print("Failed to set file permissions: " .. err)
                  end
                end)
              end
            end
          end,
        },
        gemini = {
          enable = isNixCats and bitwardenAuths.gemini and (nixCats("AI.minuet") or nixCats("AI.aider") or nixCats("AI.opencode")) or false,
          cache = true,
          bw_id = bitwardenAuths.gemini,
          localpath = (os.getenv("HOME") or "~") .. "/.secrets/gemini",
          action = function(key)
            vim.env.GEMINI_API_KEY = key
          end,
        },
      })
      local function mkClear(cmd, file)
        vim.api.nvim_create_user_command(cmd, function(_) os.remove(file) end, {})
      end
      if nixCats("AI.windsurf") then
        mkClear("ClearWindsurfAuth", windsurfAuthFile)
      end
      if nixCats("AI.minuet") then
        mkClear("ClearGeminiAuth", (os.getenv("HOME") or "~") .. "/.secrets/gemini")
      end
      mkClear("ClearBitwardenData", vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]])
    end
  },
  {
    "windsurf.nvim",
    for_cat = { cat = 'AI.windsurf', default = false },
    event = "InsertEnter",
    after = function (_)
      require("codeium").setup({ enable_chat = false, })
    end,
  },
  { import = MP:relpath "minuet", enabled = nixCats("AI.minuet") or false, },
  { import = MP:relpath "aider", enabled = nixCats("AI.aider") or false, },
  { import = MP:relpath "opencode", enabled = nixCats("AI.opencode") or false, },
  { import = MP:relpath "codecompanion", enabled = nixCats("AI.companion") or false, },
}
