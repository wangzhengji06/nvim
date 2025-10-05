return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")

      -- helper: use venv pylint if present; else fallback to PATH
      local function pylint_cmd()
        -- if Neovim was launched from an activated venv
        local venv = os.getenv("VIRTUAL_ENV")
        if venv and vim.fn.executable(venv .. "/bin/pylint") == 1 then
          return venv .. "/bin/pylint"
        end
        -- common project-local venv
        local local_venv = vim.fn.getcwd() .. "/.venv/bin/pylint"
        if vim.fn.executable(local_venv) == 1 then
          return local_venv
        end
        return "pylint" -- Mason/system fallback
      end

      -- optional: find a project rcfile if it exists
      local function pylint_extra_args(params)
        -- Neovim 0.9+ API; replace with your own finder if needed
        local rc = vim.fs.find({ ".pylintrc", "pyproject.toml", "pylintrc" }, {
          upward = true,
          path = params.bufname,
          stop = vim.loop.os_homedir(),
        })[1]
        if rc then
          -- Pylint ≥3 supports pyproject; if yours doesn’t, prefer .pylintrc
          return { "--rcfile=" .. rc, "--score=n" }
        end
        return { "--score=n" }
      end

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,

          -- ✅ Pylint wired to your venv
          null_ls.builtins.diagnostics.pylint.with({
            command = pylint_cmd(),
            -- Alternatively, this one-liner often suffices:
            -- prefer_local = ".venv/bin",
            extra_args = pylint_extra_args,
            -- Optional: add PYTHONPATH for src/ layout
            -- env = { PYTHONPATH = vim.fn.getcwd() .. "/src" },
          }),

          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.black,
        },
      })

      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
  },
}

