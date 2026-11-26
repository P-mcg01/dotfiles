require "nvchad.options"

vim.filetype.add {
  filename = { Containerfile = "dockerfile" },
  pattern = {
    -- CONTAINERS
    ["Containerfile%..*"] = "dockerfile",
    [".*%.containerfile"] = "dockerfile",
    -- ANSIBLE
    [".*/defaults/.*%.ya?ml"] = "yaml.ansible",
    [".*/vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/meta/.*%.ya?ml"] = "yaml.ansible",
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/playbook.*%.ya?ml"] = "yaml.ansible",
    [".*/host_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/molecule/.*%.ya?ml"] = "yaml.ansible",
  },
}

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
