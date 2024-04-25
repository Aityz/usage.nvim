# usage.nvim
Tracks how long you have been using Neovim, like a play-time tracker in video games.
![Showcase Image](https://raw.githubusercontent.com/Aityz/readme-assets/main/Screenshot%202024-04-25%20at%2016.51.04.png)
___
Usage.nvim is a simple plugin to track how many hours you have spent on Neovim. It is inspired by the play-time tracker in video games. The plugin is written in Lua and uses the `os.time()` function to track the time spent on Neovim. The plugin saves the time spent in a file in the `data` directory of the plugin. 

# Features
- **Tracks time spent on Neovim**: The plugin tracks the time spent on Neovim and saves it in a file.
- **Nice display UI**: The plugin informs you about your total time in either a floating window, `vim.notify`, or `echo`.

# Installation
You will need to call ``require("usage").setup()`` for this plugin to work.

<details>
    <summary>Lazy.nvim</summary>

    ```lua
    {
        "Aityz/usage.nvim",
        config = function()
            require('usage').setup()
        end
    }
    ```
</details>
<details>
    <summary>Packer.nvim</summary>
    
    ```lua
    use {
        'Aityz/usage.nvim',
        config = function()
            require('usage').setup()
        end
    }
    ```
</details>

# Configuration

```lua
require("usage").setup({
    mode = "float" -- One of "float", "notify", or "print"
})
```
