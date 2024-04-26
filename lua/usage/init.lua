local M = {}

function M.setup(opts)
	-- usage directory
	local usage_dir = vim.fn.stdpath("data") .. "/usage"

	-- if the directory does not exist, we create it
	if vim.fn.isdirectory(usage_dir) == 0 then
		vim.fn.mkdir(usage_dir, "p")
	end

	-- we store the usage in .local/share/nvim/usage
	local usage_file = usage_dir .. "/usage"

	opts = opts or {}

	local mode = opts.mode or "float" -- can be "float" or "print" or "notify"

	if vim.fn.filereadable(usage_file) == 0 then
		vim.fn.writefile({ "0" }, usage_file)
	end

	-- we write the current time to .local/share/nvim/usage_last
	local usage_last_file = usage_dir .. "/usage_last"
	local before = os.time()
	vim.fn.writefile({ before }, usage_last_file)

	-- function to update the usage file
	local function update_usage()
		local after = os.time()
		local usage_last = vim.fn.readfile(usage_last_file)[1]
		local usage = vim.fn.readfile(usage_file)[1]
		local new_usage = usage + (after - usage_last)
		vim.fn.writefile({ new_usage }, usage_file)

		-- update the last time
		vim.fn.writefile({ after }, usage_last_file)
	end

	-- now we set the Autocommands
	vim.api.nvim_create_autocmd("BufEnter", { pattern = "*", callback = update_usage })
	vim.api.nvim_create_autocmd("VimLeavePre", { pattern = "*", callback = update_usage })

	local function return_from_afk()
		-- once we come back from afk, we discard the time that we were afk
		local after = os.time()

		vim.fn.writefile({ after }, usage_last_file)
	end

	vim.api.nvim_create_autocmd("FocusGained", { pattern = "*", callback = return_from_afk })

	-- we create the :Usage command

	local function display_usage()
		-- update usage before displaying it
		update_usage()

		-- now read the usage files
		local usage = vim.fn.readfile(usage_file)[1]

		-- parse it into seconds, minutes, and hours
		local usage_hours = math.floor(usage / 3600)
		local usage_minutes = math.floor((usage % 3600) / 60)
		local usage_seconds = usage % 60

		-- format it into a string
		local usage_text = string.format(
			"You have %s, %s, and %s on Neovim.",
			usage_hours == 1 and string.format("%d hour", usage_hours) or string.format("%d hours", usage_hours),
			usage_minutes == 1 and string.format("%d minute", usage_minutes)
				or string.format("%d minutes", usage_minutes),
			usage_seconds == 1 and string.format("%d second", usage_seconds)
				or string.format("%d seconds", usage_seconds)
		)

		-- if its print or notify (mostly used for nvim-notify plugin) display the usage, and return
		if mode == "print" then
			print(usage_text)
			return
		elseif mode == "notify" then
			vim.notify(usage_text)
			return
		end

		-- calculate the length needed to create the floating window
		local width = vim.fn.strlen(usage_text)
		local height = 1

		local row = vim.fn.winheight(0) / 2 - height / 2
		local col = vim.fn.winwidth(0) / 2 - width / 2

		-- create the window options
		local window_opts = {
			relative = "editor",
			row = row,
			col = col,
			width = width,
			height = height,
			style = "minimal",
			border = "rounded",
		}

		-- create the new buffer for the floating window
		local buf = vim.api.nvim_create_buf(false, false)

		-- open the floating window_
		vim.api.nvim_open_win(buf, true, window_opts)

		-- set the buffer lines
		vim.api.nvim_buf_set_lines(buf, 0, -1, true, { usage_text })

		-- disable modifying content in the buffer
		vim.bo.modifiable = false

		-- hide the cursor
		vim.wo.cursorline = false
		vim.cmd("silent hi Cursor blend=100")
		vim.cmd("silent set winhighlight guicursor+=a:Cursor/lCursor")

		local augroup = vim.api.nvim_create_augroup("Usage", {})

		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "<buffer>",
			callback = function()
				vim.cmd("hi Cursor blend=0")
				-- and now delete this autocmd
				vim.cmd("autocmd! Usage")
			end,

			group = augroup,
		})
	end

	vim.api.nvim_create_user_command("Usage", display_usage, {
		bang = false,
	})
end

return M
