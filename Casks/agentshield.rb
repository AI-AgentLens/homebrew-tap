cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2055"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2055/agentshield_0.2.2055_darwin_amd64.tar.gz"
      sha256 "d514553dfcc64004467e90927326122d219670be2475339c7f36a03355500e2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2055/agentshield_0.2.2055_darwin_arm64.tar.gz"
      sha256 "7e3a1b8d3dd362ce416e84936bde71c541d7dfd4527ddbf2849896b22abe9f4e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2055/agentshield_0.2.2055_linux_amd64.tar.gz"
      sha256 "060a602a76f00768d01b0a6f48a4ac53da847f5ab5bcd570fb9bae15f2a294be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2055/agentshield_0.2.2055_linux_arm64.tar.gz"
      sha256 "84dbb5297d30692052ffd958bea7f237a232b2e98cf5a524a292e89e57d823cc"
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
