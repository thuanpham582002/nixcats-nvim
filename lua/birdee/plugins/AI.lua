local catUtils = require('nixCatsUtils')
return {
  {
    "AI_auths",
    for_cat = "AI",
    dep_of = { "windsurf.nvim", "minuet-ai.nvim" },
    load = function(_)
      ---@class aiauthentry
      ---@field enable boolean
      ---@field cache boolean
      ---@field bw_id string
      ---@field localpath string
      ---@field action fun(key)

      ---@param entries table<string, aiauthentry>
      local function get_auths(entries)
        local to_fetch = {}
        local cached = {}
        for name, entry in pairs(entries) do
          if entry.enable ~= false and entry.bw_id and entry.localpath and vim.fn.filereadable(entry.localpath) == 0 then
            to_fetch[name] = entry
          elseif entry.enable ~= false and entry.localpath and vim.fn.filereadable(entry.localpath) ~= 0 then
            cached[name] = entry
          end
        end
        local final = {}
        if next(to_fetch) ~= nil then
          local session, ok = require("birdee.utils").authTerminal()
          if session and ok then
            for name, entry in pairs(to_fetch) do
              local handle = io.popen("bw get --nointeraction --session " .. session .. " " .. entry.bw_id, "r")
              local key
              if handle then
                key = handle:read("*l")
                handle:close()
              end
              if entry.cache and key then
                local handle2 = io.open(entry.localpath, "w")
                if handle2 then
                  handle2:write(key)
                  handle2:close()
                end
              end
              final[name] = handle and key or nil
            end
          end
        end
        for name, entry in pairs(cached) do
          local handle = io.open(entry.localpath, "r")
          local key
          if handle then
            key = handle:read("*l")
            handle:close()
          end
          final[name] = handle and key or nil
        end
        for name, key in pairs(final) do
          if entries[name].action then
            entries[name].action(key)
          end
        end
      end

      local bitwardenAuths = nixCats.extra('bitwarden_uuids')
      local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'
      local codeiumAuthInvalid = vim.fn.filereadable(codeiumAuthFile) == 0
      get_auths({
        windsurf = {
          enable = catUtils.isNixCats and codeiumAuthInvalid and bitwardenAuths.windsurf and nixCats("AI.windsurf") or false,
          cache = false, -- <- this one is cached by its action
          bw_id = bitwardenAuths.windsurf,
          localpath = vim.fn.expand("$HOME") .. "/.secrets/windsurf",
          action = function (key)
            if vim.fn.isdirectory(codeiumDir) == 0 then
              vim.fn.mkdir(codeiumDir, 'p')
            end
            if (string.len(key) > 10) then
              local file = io.open(codeiumAuthFile, 'w')
              if file then
                file:write('{"api_key": "' .. key .. '"}')
                file:close()
                vim.loop.fs_chmod(codeiumAuthFile, 384, function(err, success)
                  if err then
                    print("Failed to set file permissions: " .. err)
                  end
                end)
              end
            end
          end,
        },
        Gemini = {
          enable = catUtils.isNixCats and bitwardenAuths.gemini and nixCats("AI.minuet") or false,
          cache = true,
          bw_id = bitwardenAuths.gemini,
          localpath = vim.fn.expand("$HOME") .. "/.secrets/gemini",
          action = function(key)
            vim.env.GEMINI_API_KEY = key
          end,
        },
      })
      if nixCats("AI.windsurf") then
        vim.api.nvim_create_user_command("ClearCodeiumAuth", function (opts)
          print(require("birdee.utils").deleteFileIfExists(codeiumAuthFile))
        end, {})
      end
      vim.api.nvim_create_user_command("ClearBitwardenData", function (opts)
        print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]]))
      end, {})
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
        provider = 'openai_fim_compatible',
        cmp = {
          enable_auto_complete = false,
        },
        blink = {
          enable_auto_complete = nixCats('blink') or false,
        },
        n_completions = 1, -- recommend for local model for resource saving
        -- I recommend beginning with a small context window size and incrementally
        -- expanding it, depending on your local computing power. A context window
        -- of 512, serves as an good starting point to estimate your computing
        -- power. Once you have a reliable estimate of your local computing power,
        -- you should adjust the context window to a larger value.
        context_ratio = 0.75,
        throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
        -- debounce the request in x milliseconds, set to 0 to disable debounce
        debounce = 250,
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
