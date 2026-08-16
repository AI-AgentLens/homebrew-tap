cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1884"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1884/agentshield_0.2.1884_darwin_amd64.tar.gz"
      sha256 "68bb9f47d7004b2846383deb7359a175cb3bf466f0256b601b15a4663485d4cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1884/agentshield_0.2.1884_darwin_arm64.tar.gz"
      sha256 "bbe6b1dda238fe9af8e6f42cb399f7f1e20665268b596c0ec3ff4d351e2dce55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1884/agentshield_0.2.1884_linux_amd64.tar.gz"
      sha256 "98c2c170e485d818c914f71383487eeeaae9f8cd68e67aec255215411f733ee4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1884/agentshield_0.2.1884_linux_arm64.tar.gz"
      sha256 "25039b8c378c4a524a6600a5104e4dfde3e3c95f63d67167f6417fe21efc6e14"
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
