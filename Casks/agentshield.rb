cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.335"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.335/agentshield_0.2.335_darwin_amd64.tar.gz"
      sha256 "a098ae1171402bf8108678dab0afdb17f91d01e3a70c75a67d3fb262cae67f9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.335/agentshield_0.2.335_darwin_arm64.tar.gz"
      sha256 "b23b8b59f486ff278ea6548004b3d77b4b6ae266bcd62f09ec0f5e022a9fe26a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.335/agentshield_0.2.335_linux_amd64.tar.gz"
      sha256 "8115ba460329bdd5a48ea2281411a9b1148cb8cc6563d6f02baf634f88b949bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.335/agentshield_0.2.335_linux_arm64.tar.gz"
      sha256 "4c81aa413326242b999e70aa407bc44daf10c8a7c2db90b85346a3507e77bd99"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
