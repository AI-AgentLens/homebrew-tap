cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1383"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1383/agentshield_0.2.1383_darwin_amd64.tar.gz"
      sha256 "f0106461f2ea785f2f0359c8c078261e90310db4a1f3662ea38c25f512a4b0dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1383/agentshield_0.2.1383_darwin_arm64.tar.gz"
      sha256 "9f3e05ed6209b2cd8a98b3bdd9dffdb187ecca752a6dd50a649f85e98075992e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1383/agentshield_0.2.1383_linux_amd64.tar.gz"
      sha256 "6e5ef08a956adbb8661d01d655074c9d85d1d9e73c0325048f11768f5c9c8b59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1383/agentshield_0.2.1383_linux_arm64.tar.gz"
      sha256 "15431ab083e1b9fbd216ea82311aa97b655a9989563dd6ef4327a1137a152fae"
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
