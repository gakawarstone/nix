from pathlib import Path

from datatypes import BinFileLinkingInfo, ConfigDirLinkingInfo


BIN_FILES_PATH = Path("~/.local/bin/").expanduser()

INCLUDED_BINS = []

INCLUDED_CONFIGS = [
    ConfigDirLinkingInfo("tmux"),
    ConfigDirLinkingInfo("alacritty"),
    ConfigDirLinkingInfo("bat"),
    ConfigDirLinkingInfo("dunst"),
    ConfigDirLinkingInfo("fish"),
    ConfigDirLinkingInfo("quickshell"),
    ConfigDirLinkingInfo("foot"),
]
