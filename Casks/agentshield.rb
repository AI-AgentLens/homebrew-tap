cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2362"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2362/agentshield_0.2.2362_darwin_amd64.tar.gz"
      sha256 "7d38ff7c79757bc3a8f50512ead3c266ffc901e8c91eed43046fe1d731f19a79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2362/agentshield_0.2.2362_darwin_arm64.tar.gz"
      sha256 "d6bdf690714a213098fe6adb25cf7654c48c48e7c55fc1c2abb834be270c521c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2362/agentshield_0.2.2362_linux_amd64.tar.gz"
      sha256 "bd535bfa437a24046af4c60ecd55841dc0399e5018e54c97a3e775e61f300518"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2362/agentshield_0.2.2362_linux_arm64.tar.gz"
      sha256 "ec7c6fff8fcb3dfa59c97995978dce1baf5a6ccb89426208f8b9b1b1c67fd9e3"
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
