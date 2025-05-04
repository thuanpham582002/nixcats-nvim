local isNixCats = require('nixCatsUtils')
return {
  {
    "AI_auths",
    enabled = isNixCats and (nixCats("AI.windsurf") or nixCats("AI.minuet")) or false,
    dep_of = { "windsurf.nvim", "minuet-ai.nvim" },
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
          enable = isNixCats and bitwardenAuths.gemini and nixCats("AI.minuet") or false,
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
  {
    "codecompanion.nvim",
    for_cat = { cat = 'AI.default', default = false },
    cmd = {
      "CodeCompanion",
      "CodeCompanionCmd",
      "CodeCompanionChat",
      "CodeCompanionAction",
    },
    keys = {
      { "<leader>cc", ":CodeCompanionChat<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[C]hat" },
      { "<leader>cv", ":CodeCompanionCmd", mode = { "n", "v", "x" }, desc = "[C]lippy[V]imcmd" },
      { "<leader>cd", ":CodeCompanionAction<CR>", mode = { "n", "v", "x" }, desc = "[C]lippy[D]o" },
    },
    after = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "ollama",
          },
          inline = {
            adapter = "qwen7",
          },
          cmd = {
            adapter = "ollama",
          }
        },
        adapters = {
          qwen7 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "qwen7", -- Give this adapter a different name to differentiate it from the default ollama adapter
              schema = {
                model = {
                  default = "qwen2.5-coder:7b",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
          llama3 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
              schema = {
                model = {
                  default = "llama3.1:latest",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "minuet-ai.nvim",
    event = "InsertEnter",
    for_cat = { cat = 'AI.minuet', default = false },
    cmd = { "Minuet" },
    after = function()
      require('minuet').setup {
        provider = 'gemini',
        cmp = {
          enable_auto_complete = false,
        },
        blink = {
          enable_auto_complete = nixCats('general.blink') or false,
        },
        n_completions = 1, -- recommend for local model for resource saving
        context_ratio = 0.75,
        throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
        debounce = 250, -- debounce the request in x milliseconds, set to 0 to disable debounce
        context_window = 512,
        request_timeout = 3,
        -- notify = "debug",
        provider_options = {
          gemini = {
            model = 'gemini-2.0-flash',
            api_key = 'GEMINI_API_KEY',
            optional = {
              generationConfig = {
                maxOutputTokens = 256,
              },
            },
          },
          openai_fim_compatible = {
            api_key = 'TERM',
            name = 'Ollama',
            stream = true,
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:7b',
            optional = {
              max_tokens = nil,
              top_p = nil,
              stop = nil,
            },
          },
        },
      }
    end,
  },
}
