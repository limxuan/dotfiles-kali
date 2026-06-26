function edit_clipboard
    # Create a temporary file
    set temp_file (mktemp /tmp/clipboard_edit.XXXXXX)

    # Get the clipboard content and save it to the temporary file
    xclip -selection clipboard -o > $temp_file 2>/dev/null

    # Open the temporary file in Neovim
    nvim $temp_file

    # Save the edited content back to the clipboard
    if test -f $temp_file
        xclip -selection clipboard -i $temp_file 2>/dev/null
        rm $temp_file
    end
end
