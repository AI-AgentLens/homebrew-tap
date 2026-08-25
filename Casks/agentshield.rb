cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1954"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1954/agentshield_0.2.1954_darwin_amd64.tar.gz"
      sha256 "b50894a35bbcdd6beea0b601db5b1a0f0667eb26e782913976c036958f5f1e42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1954/agentshield_0.2.1954_darwin_arm64.tar.gz"
      sha256 "6c1c4cefae0495773ff2ceb1da40b52714ef3be8058c07fad00ded155ab144c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1954/agentshield_0.2.1954_linux_amd64.tar.gz"
      sha256 "1223c3ecf4dcf3afbd89b6200e29fb369143c4b1b50ab0cfec1caab5b04df8b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1954/agentshield_0.2.1954_linux_arm64.tar.gz"
      sha256 "58599c7ad3f3b3ccaa62b22c08a51c9157ecfa76f7594905dcfbc7d39508b13e"
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
