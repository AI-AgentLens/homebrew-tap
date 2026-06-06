cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1218"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1218/agentshield_0.2.1218_darwin_amd64.tar.gz"
      sha256 "d2ba93924266cfd3f891a6ae37916fe875f7feffb46c773e26f909376f0ef2f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1218/agentshield_0.2.1218_darwin_arm64.tar.gz"
      sha256 "7dca1b21c9a92106ab0b53e68b52c42833fb8aec8c57f3908a7a4f31dd74ae36"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1218/agentshield_0.2.1218_linux_amd64.tar.gz"
      sha256 "8fb51461231c83a65bd1f123d9098ef429ae445ed3368556128ae6ed54afc9cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1218/agentshield_0.2.1218_linux_arm64.tar.gz"
      sha256 "f311fa90175a49bf4e91563712da2a59f484c7b118c2fd8188b99c01dcb78efa"
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
