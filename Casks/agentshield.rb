cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.964"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.964/agentshield_0.2.964_darwin_amd64.tar.gz"
      sha256 "9dfac0cd5ad992b8690a3be3e70fed7d672cb799f53663b0e142e2c6817d04af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.964/agentshield_0.2.964_darwin_arm64.tar.gz"
      sha256 "6a7f033be1e8afe6702c7677beadefd1a88d2945969dc30fd1b1bde19930b0ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.964/agentshield_0.2.964_linux_amd64.tar.gz"
      sha256 "334d0d8231a89d59f9efe64103c729200c61f88964a9fd81be6030223c0aad95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.964/agentshield_0.2.964_linux_arm64.tar.gz"
      sha256 "d04e0075373b01d53abaf990b0e8f176596c71fb49a8ae941bb59db503c1e4e0"
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
