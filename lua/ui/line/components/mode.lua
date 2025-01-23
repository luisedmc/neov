local function get_mode_group(mode)
	local groups = {
		['n'] = "NORMAL",
		['niI'] = "NORMAL i",
		['niR'] = "NORMAL r",
		['niV'] = "NORMAL v",
		['no'] = "N-PENDING",
		['i'] = "INSERT",
		['ic'] = "INSERT (completion)",
		['ix'] = "INSERT completion",
		['t'] = "TERMINAL",
		['nt'] = "NTERMINAL",
		['v'] = "VISUAL",
		['V'] = "V-LINE",
		['Vs'] = "V-LINE (Ctrl O)",
		[''] = "V-BLOCK",
		['R'] = "REPLACE",
		['Rv'] = "V-REPLACE",
		['s'] = "SELECT",
		['S'] = "S-LINE",
		[''] = "S-BLOCK",
		['c'] = "COMMAND",
		['cv'] = "COMMAND",
		['ce'] = "COMMAND",
		['r'] = "PROMPT",
		['rm'] = "MORE",
		['r?'] = "CONFIRM",
		['!'] = "SHELL"
	}
	return groups[mode] or "UNKNOWN"
end

function get_mode_component()
	local mode = vim.fn.mode()
	local mode_text = get_mode_group(mode)
	return "%#StatusLineMode#" .. mode_text
end
