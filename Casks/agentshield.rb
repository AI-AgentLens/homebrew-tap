cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2503"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2503/agentshield_0.2.2503_darwin_amd64.tar.gz"
      sha256 "bf4abf540b28a0057fa17780b700a540c13eb58b2c8f00c6c8da604492bbacc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2503/agentshield_0.2.2503_darwin_arm64.tar.gz"
      sha256 "3569dfcc401bad5050201724f0cce47497bfa4ebdf0aec634d175d348284f1cb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2503/agentshield_0.2.2503_linux_amd64.tar.gz"
      sha256 "b716b6861103e525ec6943efa645591d07abfdea988b15ac4063862fe2347143"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2503/agentshield_0.2.2503_linux_arm64.tar.gz"
      sha256 "ab73a1fa821ca33a0c8c4860903fb0a1f4b9e1b1b9d594b1f6af1b191d69590e"
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
