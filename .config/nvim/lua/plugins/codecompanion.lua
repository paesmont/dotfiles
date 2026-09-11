return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCLI",
    "CodeCompanionCodeReview",
  },
  opts = {
    opts = {
      language = "Portuguese",
    },
    -- Configurar adapters ACP
    adapters = {
      acp = {
        opencode = function()
          return require("codecompanion.adapters").extend("opencode", {
            -- Configurações do OpenCode ACP
            defaults = {
              timeout = 30000, -- 30 segundos para respostas complexas
            },
          })
        end,
      },
    },
    -- Configurar interações
    interactions = {
      chat = {
        adapter = {
          name = "opencode",
          -- model = "opencode/big-pickle",  -- Opcional: modelo específico
        },
      },
      cli = {
        agent = "opencode",
        agents = {
          opencode = {
            cmd = "opencode",
            args = { "acp" },  -- Usar ACP mode
            description = "OpenCode CLI (ACP)",
            provider = "terminal",
          },
        },
      },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat" },

    { "<leader>at", "<cmd>CodeCompanionCLI<cr>", mode = { "n", "v" }, desc = "AI terminal agent" },
    { "<leader>ar", "<cmd>CodeCompanionCodeReview<cr>", mode = "n", desc = "AI code review" },
  },
}
