cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1597"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1597/agentshield_0.2.1597_darwin_amd64.tar.gz"
      sha256 "432812c155a9affe0e7f2ffd9ec88586145ee631b3df18c4b6d9d6f9cad1d860"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1597/agentshield_0.2.1597_darwin_arm64.tar.gz"
      sha256 "f57c46b8ee5e6dac4c0b0daeeed54cc77a83e4f926b78364599369526ba12bc5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1597/agentshield_0.2.1597_linux_amd64.tar.gz"
      sha256 "ed55f1f64002c145412d73eebdddeeb70b3bd81873adda35e40055bfb795840e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1597/agentshield_0.2.1597_linux_arm64.tar.gz"
      sha256 "e8d322033fe140a6a4ba50a4ecdef7e7f2c7df9fad1d383f206c75a57843a46d"
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
