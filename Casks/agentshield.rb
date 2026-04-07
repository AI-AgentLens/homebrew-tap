cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.456"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.456/agentshield_0.2.456_darwin_amd64.tar.gz"
      sha256 "07f26ad1b53f98c7b10571de444dde4284a50c149c83ec7ef42849da28384d6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.456/agentshield_0.2.456_darwin_arm64.tar.gz"
      sha256 "fce8648ceade17fe433d6ca9ea824ef9c7e2bc8db6d7f87b0a58aef6e476e458"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.456/agentshield_0.2.456_linux_amd64.tar.gz"
      sha256 "9a96dd60e695ad0236f976860d9410b8052cd2915a7f1a07c0d407063674b455"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.456/agentshield_0.2.456_linux_arm64.tar.gz"
      sha256 "578296bce128126bca2207bef5354cb33702751b12c28c34b25db93f7e29441b"
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
