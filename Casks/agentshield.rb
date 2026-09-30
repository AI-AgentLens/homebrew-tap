cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2291"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2291/agentshield_0.2.2291_darwin_amd64.tar.gz"
      sha256 "45c4c2cddedd94d2c51c5d679914ec35fd5abfa5a095956f6c28c3876b11b35a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2291/agentshield_0.2.2291_darwin_arm64.tar.gz"
      sha256 "e74b6417e21feee8e68673f1b246869738cfa395c23cfdb1b933784c5f399ac7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2291/agentshield_0.2.2291_linux_amd64.tar.gz"
      sha256 "2fd3866bb59fd4d97e47650670c678a9e9d2024402b33f23dccc06df3201c899"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2291/agentshield_0.2.2291_linux_arm64.tar.gz"
      sha256 "975c647ac48362ea304147dbf7eecd62fa99237c7f2f3a4d3d6faccccffeacfc"
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
