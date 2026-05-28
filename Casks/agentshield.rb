cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1138"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1138/agentshield_0.2.1138_darwin_amd64.tar.gz"
      sha256 "0b99464391083f4201c566338c53b88ee741c19957cd4e163dd45cc397582118"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1138/agentshield_0.2.1138_darwin_arm64.tar.gz"
      sha256 "7a8e0101d3bcdd85aa0680f37b0d9566637928e21407680e3680cfd5878dff50"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1138/agentshield_0.2.1138_linux_amd64.tar.gz"
      sha256 "ecbebe1929e890952bd5dd5d300a45693e5e6a10a664f0e52c3394aeb57c568d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1138/agentshield_0.2.1138_linux_arm64.tar.gz"
      sha256 "f41a93611a4b8abc591f6968b0d64f11ccfa1c74de180c978405eb97da307096"
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
