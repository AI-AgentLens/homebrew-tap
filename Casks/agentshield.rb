cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.810"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.810/agentshield_0.2.810_darwin_amd64.tar.gz"
      sha256 "a087d4183ed31f9970d90051d617998b077e672bc14585771f55eab933addbe8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.810/agentshield_0.2.810_darwin_arm64.tar.gz"
      sha256 "3c0c4cafacb981223734755c69030daaea611606087c885e1c03d85e0b2f2198"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.810/agentshield_0.2.810_linux_amd64.tar.gz"
      sha256 "1ad9e4bc54459c59a20b22b5743a28416cc22947c8cb5993bda6a1c3a00c53fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.810/agentshield_0.2.810_linux_arm64.tar.gz"
      sha256 "8114307cb5330697706b1a4dac51ac565686b07cecd2fd48378d8fd6715cab41"
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
