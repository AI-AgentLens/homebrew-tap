cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1439"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1439/agentshield_0.2.1439_darwin_amd64.tar.gz"
      sha256 "c30a78531294bf5facc4e4227dafeddf07604377efcd0d16028aeabec668f333"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1439/agentshield_0.2.1439_darwin_arm64.tar.gz"
      sha256 "b804b27d2ac853d6630a087c5ad35f67764f26fff4809108c01cfbf650bd56b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1439/agentshield_0.2.1439_linux_amd64.tar.gz"
      sha256 "e6d8bed39881bb8e11e6470230da3891ea1dc9a39192ece0b381b13975327379"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1439/agentshield_0.2.1439_linux_arm64.tar.gz"
      sha256 "02497aa8159598eefa5019c9640d4a464b858b519ce1460431a92c83631f6eee"
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
