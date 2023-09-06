local dockerlint_ns = vim.api.nvim_create_namespace("dockerlint")

local function text_for_range(range)
  local srow, scol, erow, ecol = unpack(range)
  local fn = vim.fn
  if srow == erow then
    return string.sub(fn.getline(srow + 1), scol + 1, ecol)
  else
    return string.sub(fn.getline(srow + 1), scol + 1, -1) .. string.sub(vim.fn.getline(erow + 1), 1, ecol)
  end
end

local function lint(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  local lang = parser:lang()
  if not lang or lang ~= "dockerfile" then
    vim.notify('dockerlint only works for dockerfiles!', vim.log.levels.WARN)
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local query = vim.treesitter.query.get(lang, "dockerlint")
  if not query then
    return
  end

  for _, node, _ in query:iter_captures(tree:root(), bufnr) do
    local srow, scol, erow, ecol = node:range()
    local text = text_for_range({ srow, scol, erow, ecol })
    if text == ":latest" then
      vim.diagnostic.set(dockerlint_ns, bufnr, {
        {
          bufnr = bufnr,
          lnum = srow,
          end_lnum = erow,
          col = scol,
          end_col = ecol,
          severity = vim.diagnostic.severity.HINT,
          message = "Consider using a stricter tag",
        }
      })
    end
  end
end

return {
  dockerlint = lint
}
